.. meta::
   :contentType: how-to
   :experience: expert
   :area: installation
   :distribution: {DISTRO}
   :product: {PRODUCT}

.. redirect-from::

    Installation/Maintaining-a-Source-Checkout

.. _MaintainingSource:

Maintaining source checkout - how-to
====================================

.. short-description::
   Source checkouts can become outdated as ROS repositories change after the initial installation.
   In this article, you will learn how to update your repository list, fetch new source code, rebuild your workspace, and export the current checkout state.
   After you follow these steps, your source workspace will match the selected ROS repository versions.

.. showmeta::
   :order: area, contentType, experience
   :labels: area=Area, contentType=Content type, experience=Level

If you have installed ROS 2 from source, there may have been changes made to the source code since the time that you checked it out.
To keep your source checkout up to date, you will have to periodically update your ``ros2.repos`` file, download the latest sources, and rebuild your workspace.

Update your repository list
---------------------------

Each ROS 2 release includes a ``ros2.repos`` file that contains the list of repositories and their version for that release.

Latest ROS 2 {DISTRO_TITLE} branches
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you wish to checkout the latest code for ROS 2 {DISTRO_TITLE}, you can get the relevant repository list by running:

.. tab-set::

  .. tab-item:: Linux
    :sync: Linux

    .. code-block:: console

       $ cd ~/ros2_{DISTRO}
       $ mv -i ros2.repos ros2.repos.old
       $ wget https://raw.githubusercontent.com/ros2/ros2/{REPOS_FILE_BRANCH}/ros2.repos

  .. tab-item:: macOS
    :sync: macOS

    .. code-block:: console

       $ cd ~/ros2_{DISTRO}
       $ mv -i ros2.repos ros2.repos.old
       $ wget https://raw.githubusercontent.com/ros2/ros2/{REPOS_FILE_BRANCH}/ros2.repos

  .. tab-item:: Windows
    :sync: Windows

    Use a Windows command line interface:

    .. code-block:: console

       $ cd \dev\ros2_{DISTRO}
       $ curl -sk https://raw.githubusercontent.com/ros2/ros2/{REPOS_FILE_BRANCH}/ros2.repos -o ros2.repos

    Or a powershell:

    .. code-block:: console

       $ cd \dev\ros2_{DISTRO}
       $ curl https://raw.githubusercontent.com/ros2/ros2/{REPOS_FILE_BRANCH}/ros2.repos -o ros2.repos

Update your repositories
------------------------

You will notice that in the `ros2.repos <https://raw.githubusercontent.com/ros2/ros2/{REPOS_FILE_BRANCH}/ros2.repos>`__ file, each repository has a ``version`` associated with it that points to a particular commit hash, tag, or branch name.
It is possible that these versions refer to new tags/branches that your local copy of the repositories will not recognize as they are out-of-date.
Because of this, you should update the repositories that you have already checked out with the following command:

.. code-block:: console

   $ vcs custom --args remote update

Download the new source code
----------------------------

You should now be able to download the sources associated with the new repository list with:

.. tab-set::

  .. tab-item:: Linux
    :sync: Linux

    .. code-block:: console

       $ vcs import src < ros2.repos
       $ vcs pull src

  .. tab-item:: macOS
    :sync: macOS

    .. code-block:: console

       $ vcs import src < ros2.repos
       $ vcs pull src

  .. tab-item:: Windows
   :sync: Windows

   In a Windows command line interface:

   .. code-block:: console

       $ vcs import --input ros2.repos src
       $ vcs pull src

   Or in powershell:

   .. code-block:: console

       $ vcs import --input ros2.repos src
       $ vcs pull src

Rebuild your workspace
----------------------

Now that the workspace is up to date with the latest sources, remove your previous install and rebuild your workspace with, for example:

.. code-block:: console

   $ colcon build --symlink-install

Inspect your source checkout
----------------------------

During your development you may have deviated from the original state of your workspace from when you imported the repository list.
If you wish to know the versions of the set of repositories in your workspace, you can export the information using the following command:

.. tab-set::

  .. tab-item:: Linux
    :sync: Linux

    .. code-block:: console

       $ cd ~/ros2_{DISTRO}
       $ vcs export src > my_ros2.repos

  .. tab-item:: macOS
    :sync: macOS

    .. code-block:: console

       $ cd ~/ros2_{DISTRO}
       $ vcs export src > my_ros2.repos

  .. tab-item:: Windows
    :sync: Windows

    .. code-block:: console

       $ cd \dev\ros2_{DISTRO}
       $ vcs export src > my_ros2.repos

This ``my_ros2.repos`` file can then be shared with others so that they can reproduce the state of the repositories in your workspace.
