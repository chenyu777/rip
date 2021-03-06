require 'helper'

class ShellTest < Rip::Test
  test "shell prints env vars" do
    output = rip "shell"
    assert_includes "RIPDIR=", output
    assert_includes "RUBYLIB=", output
    assert_includes "PATH=", output
    assert_includes "MANPATH=", output
  end

  test "shell uses active env if RIPENV is unset" do
    output = rip "shell"
    assert_includes "active", output
  end

  test "shell uses RIPENV if set" do
    output = rip "shell" do
      ENV['RIPENV'] = 'base'
    end
    assert_includes "base", output
  end

  test "shell strips out old lib and path when changing envs" do
    output = rip "shell" do
      ENV['RIPENV'] = 'old'
      ENV['RUBYLIB'] = "#{ENV['RUBYLIB']}:#{ENV['RIPDIR']}/old/lib"
      ENV['PATH'] = "#{ENV['PATH']}:#{ENV['RIPDIR']}/old/bin"

      ENV['RIPENV'] = 'base'
    end

    assert_not_includes 'old/bin', output
    assert_not_includes 'old/lib', output
    assert_includes 'base', output
  end

  test "shell push given no env prints error" do
    output = rip "sh-push"
    assert_equal "I need a ripenv.", output.chomp
  end

  test "shell push given an invalid env prints error" do
    output = rip "sh-push blah"
    assert_equal "Can't find ripenv `blah'", output.chomp
  end

  test "shell push prints function" do
    rip "create extra"
    output = rip "sh-push extra"
    assert_match "$RIPDIR/extra/bin", output
    assert_match "$RIPDIR/extra/lib", output
    assert_match "$RIPDIR/extra/man", output
  end

  test "shell push for already pushed env prints error" do
    rip "create extra"
    output = rip "sh-push extra" do
      rip_push('extra')
    end
    assert_equal "ripenv `extra' has already been pushed", output.chomp
  end

  test "sh-pop given no env prints error" do
    output = rip "sh-pop"
    assert_equal "I need a ripenv.", output.chomp
  end

  test "shell pop given an invalid env prints error" do
    output = rip "sh-pop blah"
    assert_equal "Can't find ripenv `blah'", output.chomp
  end

  test "shell pop prints function" do
    rip "create extra"
    output = rip "sh-pop extra" do
      rip_push('extra')
    end
    assert_doesnt_include "extra", output
    assert_includes "RUBYLIB=", output
    assert_includes "PATH=", output
    assert_includes "MANPATH=", output
  end

  test "shell pop for non-pushed env prints error" do
    rip "create extra"
    output = rip "sh-pop extra"
    assert_equal "ripenv `extra' hasn't been pushed yet", output.chomp
  end
end
