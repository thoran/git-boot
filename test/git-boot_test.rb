# test/git-boot_test.rb

# 20260816
# 0.16.0

# Two ways in.  Most of this runs git-boot as a subprocess in a directory made
# for the purpose, and asserts upon the repository it leaves behind rather than
# upon anything it printed.  With no argument it does the local half and stops,
# so nothing there needs a network, a remote, or a credential.
#
# The rest loads it, which runs nothing, and calls the parts no subprocess can
# reach: everything from remote_uri onwards stands behind either a Github token
# or a live ssh host, so the only way to the descriptor is to call for it.
# load rather than require, the file having no extension to append.

require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'tmpdir'

BIN = File.expand_path('../bin/git-boot', __dir__)
load BIN

def in_repo(files: [], contents: {}, initialised: false, committed: false, origin: nil, arguments: [], home: nil)
  Dir.mktmpdir do |directory|
    Dir.chdir(directory) do
      system('git', 'init', '--quiet') if initialised || committed || origin
      files.each{|name| FileUtils.touch(name)}
      contents.each{|name, body| File.write(name, body)}
      make_history if committed
      system('git', 'remote', 'add', 'origin', origin) if origin
      stdout, stderr, status = Open3.capture3(home ? {'HOME' => home} : {}, BIN, *arguments)
      yield status.exitstatus, stdout + stderr
    end
  end
end

# A HOME of its own, holding the config file and no token beside it, so as the
# chain is walked to its end without any of this reading the real one.
def home_with_config
  home = Dir.mktmpdir
  FileUtils.mkdir_p(File.join(home, '.config', 'github'))
  File.write(File.join(home, '.config', 'github', 'config.rb'), "ACCESS_TOKEN_NAME = 'whichever'\n")
  home
end

def make_history
  FileUtils.touch('already.rb')
  system('git', 'add', 'already.rb')
  system('git', 'commit', '--quiet', '-m', 'a commit of its own')
end

def commits
  `git log --format=%s`.lines.map(&:strip).reverse
end

def tracked
  `git ls-files`.lines.map(&:strip).sort
end

# Called rather than run, this being the code a subprocess cannot get to.  What
# it decides is what to hand ImpURI#to_ssh: the git user for Github, and the
# .git extension the repository was created with.
describe 'the remote descriptor' do
  def descriptor_for(uri)
    ARGV.replace([uri])
    remote_uri
  end

  after do
    ARGV.replace([])
  end

  it 'renders a Github repository as the git user, with the extension' do
    _(descriptor_for('github.com/thoran/lineage')).must_equal 'git@github.com:thoran/lineage.git'
  end

  it 'leaves an extension which is already there' do
    _(descriptor_for('github.com/thoran/lineage.git')).must_equal 'git@github.com:thoran/lineage.git'
  end

  # A leading slash after the colon is the difference between a path from the
  # root and one from the login directory, so an ssh path keeps what it was
  # given while a URI path loses the slash which merely separated it.
  it 'keeps an ssh path from the root' do
    _(descriptor_for('user@host.com:/srv/git/thing')).must_equal 'user@host.com:/srv/git/thing.git'
  end

  it 'keeps an ssh path from the login directory' do
    _(descriptor_for('user@host.com:thing')).must_equal 'user@host.com:thing.git'
  end

  # The git user is Github's alone, and imposing it everywhere would push to
  # every other host as the wrong user.
  it 'leaves the user alone for anything but Github' do
    _(descriptor_for('someone@host.com:thing')).must_match(/\Asomeone@/)
    _(github?).must_equal false
  end

  it 'knows Github from anywhere else' do
    ARGV.replace(['github.com/thoran/lineage'])
    _(github?).must_equal true
    ARGV.replace(['user@host.com:thing'])
    _(github?).must_equal false
  end
end

# The case which has actually bitten, asserted upon directly now rather than
# through what a run of git-boot happened to commit.
describe 'entries_to_add' do
  def in_directory(*files)
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        FileUtils.mkdir('.git')
        files.each{|name| FileUtils.touch(name)}
        yield
      end
    end
  end

  it 'leaves out the directory entries, .git and .gitignore' do
    in_directory('a.rb', '.gitignore', '.envrc') do
      _(entries_to_add.sort).must_equal %w{.envrc a.rb}
    end
  end

  it 'is empty where there is nothing but a .gitignore' do
    in_directory('.gitignore') do
      _(entries_to_add).must_be_empty
    end
  end
end

describe 'git-boot in an empty directory' do
  # The root commit is made unconditionally so as every real commit has a
  # parent and can be amended, reset onto, or rebased in the ordinary way.
  it 'makes the root commit and nothing else' do
    in_repo do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
      _(tracked).must_equal ['.gitignore']
    end
  end
end

describe 'git-boot in a directory with files' do
  it 'commits the .gitignore first and the files after' do
    in_repo(files: %w{a.rb b.rb}) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore', '+ *']
      _(tracked).must_equal %w{.gitignore a.rb b.rb}
    end
  end

  it 'leaves the root commit with no parent and the second with one' do
    in_repo(files: %w{a.rb}) do |_status, _output|
      _(`git rev-list --max-parents=0 HEAD`.lines.length).must_equal 1
      _(`git log --format=%s --max-parents=0`.strip).must_equal '+ .gitignore'
    end
  end
end

# The file the root commit carries was empty for as long as git-boot had been
# making it, and an empty .gitignore reads at a glance as though the rules are
# there.  Thirty-one repositories were booted with one before it was noticed.
describe 'the .gitignore the root commit carries' do
  it 'is the template rather than an empty file' do
    in_repo do |status, _output|
      _(status).must_equal 0
      _(File.read('.gitignore')).must_equal File.read(gitignore_template_path)
    end
  end

  it 'holds the .claude rule, which an empty file was letting through' do
    in_repo do |_status, _output|
      _(File.read('.gitignore')).must_include '.claude'
    end
  end

  # A .gitignore already in the directory is the repository's own, whatever it
  # holds, and the root commit takes it as it stands rather than over it.
  it 'leaves a .gitignore which is there already as it stands' do
    in_repo(contents: {'.gitignore' => "*.swp\n"}) do |status, _output|
      _(status).must_equal 0
      _(File.read('.gitignore')).must_equal "*.swp\n"
      _(commits).must_equal ['+ .gitignore']
    end
  end

  # The template ships beside bin and lib rather than inside either, so it is
  # the one thing a package can leave behind while everything else still runs.
  it 'ships where bin/git-boot looks for it' do
    _(File.exist?(gitignore_template_path)).must_equal true
  end
end

# A repository with history has its own root commit already, and a second one
# grafted onto the tip is neither parentless nor wanted.  What is booted is a
# directory with no commits, which is not the same as one with no .git.
describe 'git-boot in a repository which already has commits' do
  it 'adds no commit of its own' do
    in_repo(committed: true) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['a commit of its own']
    end
  end

  it 'leaves untracked files untracked rather than sweeping them in' do
    in_repo(files: %w{scratch.rb}, committed: true) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['a commit of its own']
      _(tracked).must_equal ['already.rb']
    end
  end

  it 'creates no .gitignore where there was none' do
    in_repo(committed: true) do |_status, _output|
      _(File.exist?('.gitignore')).must_equal false
    end
  end
end

# Whether the repository is made private cannot be asserted without the API and
# a token, so what is tested is that the switch is consumed: an undeclared
# switch is left in ARGV, and ARGV[0] is read as the repository to create.
describe 'git-boot --private' do
  it 'is taken as a switch rather than as the repository to create' do
    in_repo(arguments: %w{--private}) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
      _(`git remote`.strip).must_be_empty
    end
  end

  it 'is taken as a switch in its short form too' do
    in_repo(arguments: %w{-p}) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
    end
  end

  # It stands before the URI without swallowing it, which is what a switch
  # taking an argument would do.
  it 'leaves the repository argument alone' do
    in_repo(
      committed: true,
      origin: 'git@example.com:someone/other.git',
      arguments: %w{--private github.com/thoran/whatever}
    ) do |status, output|
      _(status).wont_equal 0
      _(output).must_match(/already has a remote named origin/)
    end
  end
end

# The config file names the token but does not hold it, so with no token beside
# it the chain runs to its end and stops before anything is created.  That is
# the one path which reads the config file, and so the one which can say how
# often it is read.
describe 'git-boot reading the access token config' do
  it 'stops at the end of the chain rather than reaching the API' do
    in_repo(committed: true, home: home_with_config, arguments: %w{github.com/thoran/whatever}) do |status, output|
      _(status).wont_equal 0
      _(output).must_match(/No access token/)
      _(`git remote`.strip).must_be_empty
    end
  end

  # The config file defines constants, so reading it a second time warns once
  # per constant, and those warnings buried the real error when this was found.
  it 'reads the config file once, whatever it is asked' do
    in_repo(committed: true, home: home_with_config, arguments: %w{github.com/thoran/whatever}) do |_status, output|
      _(output).wont_match(/already initialized constant/)
    end
  end

  # Whatever git-boot says should be its own. A notice from a dependency is
  # noise on every run, and it was four such lines which hid the one above.
  it 'says nothing on behalf of its dependencies' do
    in_repo(committed: true, home: home_with_config, arguments: %w{github.com/thoran/whatever}) do |_status, output|
      _(output).wont_match(/retry middleware/)
      _(output).wont_match(/warning:/)
    end
  end
end

# Refused before anything remote is made, so as neither an empty repository is
# left on the far end nor a push sent to a remote which was not named here.
describe 'git-boot where origin is taken' do
  it 'refuses, and says what origin already points at' do
    in_repo(
      committed: true,
      origin: 'git@example.com:someone/other.git',
      arguments: %w{github.com/thoran/whatever}
    ) do |status, output|
      _(status).wont_equal 0
      _(output).must_match(/already has a remote named origin/)
      _(output).must_match(/git@example\.com:someone\/other\.git/)
    end
  end

  it 'does not disturb the remote which is there' do
    in_repo(
      committed: true,
      origin: 'git@example.com:someone/other.git',
      arguments: %w{github.com/thoran/whatever}
    ) do |_status, _output|
      _(`git remote get-url origin`.strip).must_equal 'git@example.com:someone/other.git'
      _(`git remote`.lines.map(&:strip)).must_equal ['origin']
    end
  end

  # With no argument there is no remote half to reach, so an origin already
  # there is nothing to do with anything.
  it 'does not refuse where no remote was asked for' do
    in_repo(committed: true, origin: 'git@example.com:someone/other.git') do |status, _output|
      _(status).must_equal 0
    end
  end
end

describe 'git-boot in a directory which is already a repository' do
  it 'does not reinitialise it' do
    in_repo(initialised: true) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
    end
  end

  it 'still adds the files it finds' do
    in_repo(files: %w{a.rb b.rb}, initialised: true) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore', '+ *']
      _(tracked).must_equal %w{.gitignore a.rb b.rb}
    end
  end
end

# entries_to_add reads Dir['.*'], which includes '.', '..' and '.git', and
# adding any of those is either a no-op or an error.  This is the case which
# has actually bitten.
describe 'git-boot in a directory of dotfiles' do
  it 'adds the dotfiles without adding the directory entries or .git' do
    in_repo(files: %w{.envrc .tool-versions}) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore', '+ *']
      _(tracked).must_equal %w{.envrc .gitignore .tool-versions}
    end
  end

  # The template governs the second commit as much as it does any later one:
  # .ruby-version is a rule in it, so a directory holding one boots without it.
  it 'leaves out a dotfile the template ignores' do
    in_repo(files: %w{.envrc .ruby-version}) do |status, _output|
      _(status).must_equal 0
      _(tracked).must_equal %w{.envrc .gitignore}
    end
  end

  # Everything present being ignored is not the same as nothing being present,
  # and asking git to commit an empty index earns a message rather than a commit.
  it 'makes no second commit where everything present is ignored' do
    in_repo(files: %w{.ruby-version}) do |status, output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
      _(output).wont_include 'nothing to commit'
    end
  end

  # A .gitignore already there is the root commit's own file, so it must not
  # earn a second commit of its own.
  it 'makes no second commit where .gitignore is all there is' do
    in_repo(files: %w{.gitignore}) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
      _(tracked).must_equal ['.gitignore']
    end
  end
end
