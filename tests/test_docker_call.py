#!/usr/bin/env python3

"""
@file test_docker_call.py
@author Anthony Remazeilles
@brief check the computation runs as expected

Copyright (C) 2019 Tecnalia Research and Innovation
Distributed under the Non-Profit Open Software License 3.0 (NPOSL-3.0).

"""

import os
import io
import unittest
import tempfile

class DockerCallTest(unittest.TestCase):
    """gather program tests
    """

    DOCKER_IMAGE = "pi_csic_docker_image"

    def setUp(self):
        """Common initialization operations
        """

        print("Setting up the test")

        rel_path = os.path.dirname(__file__)
        print("Done")

        self.input_data_path = os.path.abspath(os.getcwd() + "/" + rel_path + "/data/input")

        self.output_groundtruth_path = os.path.abspath(os.getcwd() + "/" + rel_path + "/data/output")

        print("Input data in: {}".format(self.input_data_path))

        self.output_data_path = tempfile.mkdtemp()
        os.chmod(self.output_data_path, 0o777)

        #tmp_content = os.listdir("/tmp")
        #print("TMP folder content BEFORE: {}".format(tmp_content))

        #if not os.path.exists(self.output_data_path):
        #    os.umask(0)
        #    os.makedirs(self.output_data_path, mode=0o777)

        #tmp_content = os.listdir(self.output_data_path)
        #print("result folder content: {}".format(tmp_content))

        #tmp_content = os.listdir("/tmp")
        #print("TMP folder content AFTER: {}".format(tmp_content))

        # preparing the generation command
        self.command = "docker run --rm -v {}:/in -v {}:/out {} ".format(self.input_data_path,
                                                                         self.output_data_path,
                                                                         self.DOCKER_IMAGE)

        self.command += "./run_pi /in/subject_10_trial_01.csv /in/subject_10_anthropometry.yaml /out"

        print("Commande generated: \n{}".format(self.command))

    def test_call_docker(self):
        """test the docker component with stored input and output

        """

        print("Launching docker command")
        # TODO how to catch the result of the command (error or success)
        os.system(self.command)

        print("Docker command launched")

        # check generated files
        output_files = os.listdir(self.output_data_path)
        output_files_expected = os.listdir(self.output_groundtruth_path)

        self.assertCountEqual(output_files, output_files_expected)

        # Check the content of each file

        for filename in output_files:
            print("comparing file: {}".format(filename))

            file_generated = self.output_data_path + "/" + filename

            lines_generated = list()
            with open(file_generated) as f:
                for line in f:
                    lines_generated.append(line)

            file_groundtruth = self.output_groundtruth_path + "/" + filename

            lines_groundtruth = list()
            with open(file_groundtruth) as f:
                for line in f:
                    lines_groundtruth.append(line)

            # print("Comparing:\n{}\n with \n{}".format(lines_generated, lines_groundtruth))
            self.assertListEqual(lines_generated, lines_groundtruth)

        print("Done")


if __name__ == '__main__':
    print("test_docker_call -- begin: {}".format(os.environ.get('DOCKER_IMAGE')))

    DockerCallTest.DOCKER_IMAGE = os.environ.get('DOCKER_IMAGE', DockerCallTest.DOCKER_IMAGE)
    # TODO using https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    # but it is mentioned as not preferrable.
    unittest.main()
