#!/usr/bin/env python3

"""
@file test_docker_call.py
@author Anthony Remazeilles
@brief check the computation runs as expected

Copyright (C) 2020 Tecnalia Research and Innovation
Distributed under the Apache 2.0 (Apache 2.0).

"""

import os
import io
import unittest
import tempfile
import logging
import sys
import xml.dom.minidom
# for dind management
# import re
# import docker
# import socket
# Check https://stackoverflow.com/questions/32899/how-do-you-generate-dynamic-parameterized-unit-tests-in-python

# for dind management,
# see https://gist.github.com/dpfoose/f96d4e4b76c2e01265619d545b77987a


# def in_docker():
#     """
#     Check if running in Docker
#     :return: Whether or not this is running in Docker container
#     """
#     try:
#         with open('/proc/1/cgroup', 'rt') as cgroup_file:
#             return 'docker' in cgroup_file.read()
#     except FileNotFoundError as e:
#         return False


# def translate_path(path):
#     """
#     :param path: A string representing a path within the container
#     :return: A string representing a path on the host (or the original path if the path is not in a bound volume)
#     """
#     binds = get_binds()
#     if path in binds.keys():
#         return binds[path]
#     exps = ['(%s)/(.*)' % key for key in binds.keys()]
#     print('path: %s' % path)
#     for exp in exps:
#         result = re.search(exp, path)
#         if result:
#             print('%s/%s' % (binds[result.group(1)], result.group(2)))
#             return '%s/%s' % (binds[result.group(1)], result.group(2))
#     raise ValueError('Path %s not present in a bind mount. Volume mount will fail when running this in Docker.' % path)


# def get_current_container():
#     """
#     Will raise ValueError if there is no container with the same hostname as the environment this is running in
#     Which indicates that this is not a docker container, or that /var/run/docker.sock is not bind mounted to
#     /var/run/docker.sock on the host (i.e. this is a container which is also a docker host).
#     :return: A dictionary containing information about the container this is running in obtained using docker api
#     """
#     hostname = socket.gethostname()
#     client = docker.from_env()
#     for container in client.containers.list():
#         if container.attrs['Config']['Hostname'] == hostname:
#             return container
#     raise ValueError('Not running in Docker container')


# def get_binds():
#     """
#     :return: A dictionary with paths in the container as keys and paths on the host as values
#     """
#     container = get_current_container()
#     return {bind.split(':')[1]: bind.split(':')[0] for bind in container.attrs['HostConfig']['Binds']}

class DockerCallTest(unittest.TestCase):
    """gather program tests
    """

    DOCKER_IMAGE = "pi_beat"
    TEST_PLAN = "test_plan.xml"

    def setUp(self):
        """Common initialization operations
        """

        self.log = logging.getLogger("test_log")

        self.log.debug("Setting up the test")

        self.log.debug("Testing image: {}".format(self.DOCKER_IMAGE))
        self.log.debug("Test plan in : {}".format(self.TEST_PLAN))


        rel_path = os.path.dirname(__file__)
        test_folder = os.path.abspath(os.getcwd() + "/" + rel_path)
        ## Read the test plan
        plan_file = self.TEST_PLAN
        self.log.debug("test plan file: {}".format(plan_file))
        rel_path = os.path.dirname(self.TEST_PLAN)
        self.log.debug("rel_path: {}".format(rel_path))

        test_folder = os.path.abspath(os.getcwd() + "/" + rel_path)
        self.log.debug("test folder: {}".format(test_folder))

        plan_xml = xml.dom.minidom.parse(plan_file)
        all_test = plan_xml.getElementsByTagName("test")
        self.log.debug("number of tests: {}".format(all_test.length))

        test_detail = []

        for one_test in all_test:
            one_test_detail = {}
            one_test_detail['pi_name'] = one_test.getAttribute('pi_name')
            one_test_detail['parameters'] = one_test.getAttribute('parameters')
            one_test_detail['input_folder'] = one_test.getAttribute('input_folder')
            one_test_detail['output_folder'] = one_test.getAttribute('output_folder')

            # putting absolute path in path variables
            one_test_detail['input_folder'] = test_folder + '/' + one_test_detail['input_folder']
            one_test_detail['output_folder'] = test_folder + '/' + one_test_detail['output_folder']

            test_detail.append(one_test_detail)

        self.log.debug("Testing plan: {}".format(test_detail))

        self.test_detail = test_detail

    def test_call_docker(self):
        """test the docker component with stored input and output

        """

        # if in_docker():
        #     print("Testing within a docker!")
        # else:
        #     print("Testing not done in docker")

        for i, one_test in enumerate(self.test_detail):

            msg_test = "test {} on {}".format(i, one_test['pi_name'])
            with self.subTest(msg=msg_test):
                self.log.debug("Launching test {}".format(i))

                #output_data_path = tempfile.mkdtemp()
                #os.chmod(output_data_path, 0o777)

                ##os.makedirs('tmp_out')
                output_data_path = "/builds/eurobench/pi_csic/mnt"
                # preparing the generation command
                self.command = "docker run --rm -v {}:/in -v {}:/out {} ".format(one_test['input_folder'],
                                                                                output_data_path,
                                                                                self.DOCKER_IMAGE)

                self.command += one_test['pi_name'] + ' ' + one_test['parameters']

                self.log.debug("Command generated: \n{}".format(self.command))

                self.log.info("Launching docker command")
                # TODO how to catch the result of the command (error or success)
                os.system(self.command)

                self.log.info("Docker command launched")

                # check generated files
                output_groundtruth_path = one_test['output_folder']

                output_files = os.listdir(output_data_path)
                output_files_expected = os.listdir(output_groundtruth_path)

                self.assertCountEqual(output_files, output_files_expected, msg="Missing generated files")

                # Check the content of each file

                for filename in output_files:
                    self.log.debug("comparing file: {}".format(filename))

                    file_generated = output_data_path + "/" + filename

                    lines_generated = list()
                    with open(file_generated) as f:
                        for line in f:
                            lines_generated.append(line)

                    file_groundtruth = output_groundtruth_path + "/" + filename

                    lines_groundtruth = list()
                    with open(file_groundtruth) as f:
                        for line in f:
                            lines_groundtruth.append(line)

                    # print("Comparing:\n{}\n with \n{}".format(lines_generated, lines_groundtruth))
                    self.assertListEqual(lines_generated, lines_groundtruth, msg="File {} differs".format(filename))

                    self.log.info("Test completed")
        self.log.info("All tests completed")


if __name__ == '__main__':
    print("test_docker_call -- testing image: {}".format(os.environ.get('DOCKER_IMAGE')))
    print("test_docker_call -- testing plan: {}".format(os.environ.get('TEST_PLAN')))

    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

    DockerCallTest.DOCKER_IMAGE = os.environ.get('DOCKER_IMAGE', DockerCallTest.DOCKER_IMAGE)
    DockerCallTest.TEST_PLAN = os.environ.get('TEST_PLAN', DockerCallTest.TEST_PLAN)
    # TODO using https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    # but it is mentioned as not preferrable.
    unittest.main()
