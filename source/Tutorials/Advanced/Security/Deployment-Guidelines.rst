.. redirect-from::

    Tutorials/Security/Deployment-Guidelines

.. _Deployment-Guidelines:

Deployment Guidelines
======================

**Goal:** Understand the best practices when deploying security artifacts into production systems.

**Tutorial level:** Advanced

**Time:** 20 minutes

.. contents:: Contents
   :depth: 2
   :local:


Background
----------

Typical deployment scenarios oftenly involve shipping containerized applications, or packages, into remote systems.
Special attention should be payed when deploying security enabled applications, requiring users to reason about the sensitivity of packaged files.

Complying with the `DDS Security standard <https://www.omg.org/spec/DDS-SECURITY/1.1/About-DDS-SECURITY/>`_,
the ``sros2`` package provides a collection of utilities for managing security under ROS2 environments, in a highly modular and flexible fashion.

A basic core guidelines on how to organize the different certificates, keys and directories remains to be a critical factor in order to avoid compromising the security of the system.
This includes protection-awareness and criteria for selecting the minimum set of necessary files to be deployed upon remote production systems for minimizing security exposure.

Prerequisites
-------------

* A docker installation available. Please refer to the installation steps detailed in `Docker installation <https://docs.docker.com/engine/install/>`_.
* (Recommended) A basic understanding on `ROS2 Security design <https://design.ros2.org/articles/ros2_dds_security.html>`_.
* (Recommended) Previous tutorials completion.

General Guidelines
------------------

ROS2 leverages DDS Security extension to ensure security on message exchanges within the same enclave.
The different signed files and certificates within an enclave are generated from the private keys and certificates of a `Certificate Authority (CA) <https://en.wikipedia.org/wiki/Certificate_authority>`_ trusted entity.
In fact, two different CA's can be selected for identity and permissions, per enclave.
Those CA artifacts are stored inside ``private/`` and ``public/`` sub-directories of a `Keystore <https://design.ros2.org/articles/ros2_security_enclaves.html>`_ with the following folder structure:

.. code-block:: text

  keystore
  ├── enclaves
  │   └── ...
  │       └── ...
  ├── private
  │   └── ...
  └── public
      └── ...

A good practice for the creation and usage of a certain Certificate Authority on a typical deployment over a production system, is to:

  (1) Create it within the organization system intended for internal use only.
  (2) Generate/modify desired enclaves.
  (3) Ship ``public/`` alongside with corresponding ``enclaves/`` into the different remote production systems during setup, depending on the communication needs (not all remote systems may need to interact with each other).
  (4) Keep and protect ``private/`` keys and/or certification requests in the organization.

It is important to note that if ``private/`` files are lost, it won't be possible to change access permissions, adding or modifying security profiles anymore.

In addition, further practices may be taken into consideration:

* Granting read-only permissions to the ``enclaves/`` directory contents.
* If a PKCS#11 compliant URI is given for generating enclave's private keys, a `Hardware Security Module (HSM) <https://en.wikipedia.org/wiki/Hardware_security_module>`_ could be used to store them.

The following table depicts a summary of the previous statements relating the Keystore directory with the Recommended location:

+------------------------+--------------+---------------+---------------------+
| Directory / Location   | Organization | Remote System | Material Sensitivity|
+========================+==============+===============+=====================+
| public                 |       ✓      |       ✓       |         Low         |
+------------------------+--------------+---------------+---------------------+
| private                |       ✓      |       ✕       |         High        |
+------------------------+--------------+---------------+---------------------+
| enclaves               |       ✓      |       ✓       |        Medium       |
+------------------------+--------------+---------------+---------------------+


Building a deployment scenario
------------------------------

To illustrate a simple deployment scenario, a docker image will be built intented to be the remote production system actor.
In this example, localhost will serve as the organization's system.
To test security capabilities, a secure listener will be launched on the remote system, whereas a secure talker will be launched on the localhost.
Let's start by creating a workspace tree with the following sub-folders:

.. code-block:: bash

  mkdir -p ~/deploy_gd_tutorial/organization_system
  mkdir ~/deploy_gd_tutorial/remote_system
  mkdir ~/deploy_gd_tutorial/keystore

Similarly to previous tutorials, intialize a new keystore tree directory.
This will create enclaves/ public/ and private/ directories, which are explained in more detail in `ROS2 Security enclaves <https://design.ros2.org/articles/ros2_security_enclaves.html>`_.

.. code-block:: bash

  # Source ROS installation
  source /opt/ros/${ROS_DISTRO}/setup.bash
  # Initialize a new keystore directory
  ros2 security create_keystore ~/deploy_gd_tutorial/keystore

At this point, step into the remote_system workspace, create the corresponding enclave and copy just the public/ and enclaves/ directories to the current one.
Those security artifacts will be needed by the remote system to enable listener's security.
For the sake of simplicity, the same CA is used within this enclave for both, identity and permissions.
Note that private/ folder is not moved but left in localhost (organization).

.. code-block:: bash

  # Move to remote's system path
  cd ~/deploy_gd_tutorial/remote_system
  # Create an enclave for the secure listener
  ros2 security create_enclave ~/deploy_gd_tutorial/keystore /talker_listener/listener
  # Ship enclaves/ and public/ directories only, minimizing security threat
  cp -R ../keystore/enclaves ../keystore/public .

For the purpose of running a secure listener at the docker image startup, a new ``entrypoint.sh`` file is required with the following content:

.. code-block:: bash

  #!/bin/bash
  source /opt/ros/${ROS_DISTRO}/setup.bash
  ros2 run demo_nodes_cpp listener --ros-args --enclave /talker_listener/listener $@

In order to build a new docker image, a Dockerfile is also needed within this directory.
Create a new file ``Dockerfile`` in the same directory with preferred text editor.

.. code-block:: bash

  ARG ROS_DISTRO=humble
  FROM ros:${ROS_DISTRO}-ros-base

  RUN apt-get update && apt-get install -y \
        ros-${ROS_DISTRO}-demo-nodes-cpp \
        ros-${ROS_DISTRO}-demo-nodes-py && \
      rm -rf /var/lib/apt/lists/*

  ARG KEYSTORE_DIR=/keystore

  RUN mkdir -p ${KEYSTORE_DIR}/enclaves \
    mkdir ${KEYSTORE_DIR}/public

  COPY enclaves ${KEYSTORE_DIR}/enclaves
  COPY public ${KEYSTORE_DIR}/public

  ENV ROS_SECURITY_KEYSTORE=${KEYSTORE_DIR}
  ENV ROS_SECURITY_ENABLE=true
  ENV ROS_SECURITY_STRATEGY=Enforce

  COPY entrypoint.sh /entrypoint.sh

  ENTRYPOINT ["/entrypoint.sh"]

Build the docker image with the command:

.. code-block:: bash

  # Build remote's system image
  docker build -t ros2_security/deployment_tutorial .

Finally, create an enclave for the local talker node.

.. code-block:: bash

  # Go to organization_system path
  cd ~/deploy_gd_tutorial/organization_system
  # Create secure talker's enclave
  ros2 security create_enclave ~/deploy_gd_tutorial/keystore /talker_listener/talker


Running the example
-------------------

Launch the following commands in two different terminals:

.. tabs::

    .. tab:: TERMINAL 1

        .. code-block:: bash

            # Start remote system container
            docker run -it ros2_security/deployment_tutorial

    .. tab:: TERMINAL 2

        .. code-block:: bash

            # Export ROS security environment variables
            export ROS_SECURITY_KEYSTORE=~/deploy_gd_tutorial/keystore
            export ROS_SECURITY_ENABLE=true
            export ROS_SECURITY_STRATEGY=Enforce

            # Source ROS installation and run the talker
            source /opt/ros/${ROS_DISTRO}/setup.bash
            ros2 run demo_nodes_cpp talker --ros-args --enclave /talker_listener/talker

With the realization of above steps, the subsequent output is obtained:

.. raw:: html

    <video width=100% height=auto autoplay loop controls muted>
        <source src="../../../_static/security_deployment_tutorial.mp4">
        Your browser does not support the video tag.
    </video>


