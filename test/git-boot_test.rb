# test/git-boot_test.rb

# 20260807
# 0.13.0

# git-boot is run as a subprocess in a directory made for the purpose, and
# what is asserted is the state of the repository it leaves behind rather than
# anything it printed.  With no argument it does the local half and stops, so
# nothing here needs a network, a remote, or a credential.

require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'tmpdir'

BIN = File.expand_path('../bin/git-boot', __dir__)

def in_repo(files: [], initialised: false, committed: false, origin: nil, arguments: [])
  Dir.mktmpdir do |directory|
    Dir.chdir(directory) do
      system('git', 'init', '--quiet') if initialised || committed || origin
      files.each{|name| FileUtils.touch(name)}
      make_history if committed
      system('git', 'remote', 'add', 'origin', origin) if origin
      stdout, stderr, status = Open3.capture3(BIN, *arguments)
      yield status.exitstatus, stdout + stderr
    end
  end
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
    in_repo(files: %w{.envrc .ruby-version}) do |status, _output|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore', '+ *']
      _(tracked).must_equal %w{.envrc .gitignore .ruby-version}
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
