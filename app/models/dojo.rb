# See cyber-dojo-model.pdf

class Dojo

  def languages; @languages ||= Languages.new(self, external_root); end
  def exercises; @exercises ||= Exercises.new(self, external_root); end
  def    caches; @caches    ||=    Caches.new(self, external_root); end
  def     katas; @katas     ||=     Katas.new(self, external_root); end

  def  starter;  @starter ||= external_object; end
  def   runner;   @runner ||= external_object; end
  def    shell;    @shell ||= external_object; end
  def     disk;     @disk ||= external_object; end
  def      log;      @log ||= external_object; end
  def      git;      @git ||= external_object; end

  def root_dir
    # /var/www/cyber-dojo
    File.expand_path('../..', File.dirname(__FILE__))
  end

  private

  include NameOfCaller

  def external_root
    var = 'CYBER_DOJO_' + name_of(caller).upcase + '_ROOT'
    default = "#{root_dir}/#{name_of(caller)}"
    root = ENV[var] || default
    root + (root.end_with?('/') ? '' : '/')
  end

  def external_object
    key = name_of(caller)
    var = 'CYBER_DOJO_' + key.upcase + '_CLASS'
    Object.const_get(ENV[var] || object_defaults(key)).new(self)
  end

  def object_defaults(key)
    # be very careful about recursion here since
    # default_runner uses runner.installed? checks
    # which will lead to shell.exec calls...
    return default_runner if key == 'runner'
    @defaults ||= {
      'starter'  => 'HostDiskAvatarStarter',
      'shell'    => 'HostShell',
      'disk'     => 'HostDisk',
      'log'      => 'HostLog',
      'git'      => 'HostGit'
    }
    @defaults[key]
  end

  def default_runner
    return 'DockerMachineRunner' if DockerMachineRunner.new(self).installed?
    return 'DockerRunner'        if DockerRunner.new(self).installed?
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External paths can be set via these environment variables.
#
# CYBER_DOJO_LANGUAGES_ROOT
# CYBER_DOJO_EXERCISES_ROOT
# CYBER_DOJO_KATAS_ROOT
# CYBER_DOJO_CACHES_ROOT
#
# External objects can be set via these environment variables.
#
# CYBER_DOJO_STARTER_CLASS
# CYBER_DOJO_RUNNER_CLASS
# CYBER_DOJO_SHELL_CLASS
# CYBER_DOJO_DISK_CLASS
# CYBER_DOJO_LOG_CLASS
# CYBER_DOJO_GIT_CLASS
#
# The main reason for this arrangement is testability.
# For example, I can run controller tests by setting the
# environment variables, then run the test which issue
# a GET/POST, let the call work its way through the rails stack,
# eventually reaching dojo.rb where it creates
# Disk/Runner/Git/Shell/etc objects as named in ENV[]
#
# The external objects are held using
#    @name ||= ...
# This could be coded without the ||= cache since
# the externals are stateless - the externals they
# represent maintain the state.
# I use ||= partly for optimization and partly for testing
# (where it is handy that it is the same object)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
