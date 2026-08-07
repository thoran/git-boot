# test/git-boot_test.rb

# 20260807
# 0.12.0

# git-boot is run as a subprocess in a directory made for the purpose, and
# what is asserted is the state of the repository it leaves behind rather than
# anything it printed.  With no argument it does the local half and stops, so
# nothing here needs a network, a remote, or a credential.

require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'tmpdir'

BIN = File.expand_path('../bin/git-boot', __dir__)

def in_repo(files: [], initialised: false)
  Dir.mktmpdir do |directory|
    Dir.chdir(directory) do
      system('git', 'init', '--quiet') if initialised
      files.each{|name| FileUtils.touch(name)}
      _stdout, _stderr, status = Open3.capture3(BIN)
      yield status.exitstatus
    end
  end
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
    in_repo do |status|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
      _(tracked).must_equal ['.gitignore']
    end
  end
end

describe 'git-boot in a directory with files' do
  it 'commits the .gitignore first and the files after' do
    in_repo(files: %w{a.rb b.rb}) do |status|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore', '+ *']
      _(tracked).must_equal %w{.gitignore a.rb b.rb}
    end
  end

  it 'leaves the root commit with no parent and the second with one' do
    in_repo(files: %w{a.rb}) do |_status|
      _(`git rev-list --max-parents=0 HEAD`.lines.length).must_equal 1
      _(`git log --format=%s --max-parents=0`.strip).must_equal '+ .gitignore'
    end
  end
end

describe 'git-boot in a directory which is already a repository' do
  it 'does not reinitialise it' do
    in_repo(initialised: true) do |status|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
    end
  end

  it 'still adds the files it finds' do
    in_repo(files: %w{a.rb b.rb}, initialised: true) do |status|
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
    in_repo(files: %w{.envrc .ruby-version}) do |status|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore', '+ *']
      _(tracked).must_equal %w{.envrc .gitignore .ruby-version}
    end
  end

  # A .gitignore already there is the root commit's own file, so it must not
  # earn a second commit of its own.
  it 'makes no second commit where .gitignore is all there is' do
    in_repo(files: %w{.gitignore}) do |status|
      _(status).must_equal 0
      _(commits).must_equal ['+ .gitignore']
      _(tracked).must_equal ['.gitignore']
    end
  end
end
