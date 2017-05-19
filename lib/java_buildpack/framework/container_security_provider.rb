# Cloud Foundry Java Buildpack
# Copyright 2013-2017 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/qualify_path'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for contributing a container-based security provider to an application.
    class ContainerSecurityProvider < JavaBuildpack::Component::VersionedDependencyComponent
      include JavaBuildpack::Util

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_jar
        @droplet.copy_resources
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        @droplet.additional_libraries << (@droplet.sandbox + jar_name)
        @droplet.java_opts
          .add_system_property('java.ext.dirs', ext_dirs)
          .add_system_property('java.security.properties', @droplet.sandbox + 'java.security')
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        true
      end

      private

      def ext_dir
        @droplet.sandbox
      end

      def ext_dirs
        "#{qualify_path(@droplet.java_home.root + 'lib/ext', @droplet.root)}:" \
        "#{qualify_path(ext_dir, @droplet.root)}"
      end

    end

  end
end
