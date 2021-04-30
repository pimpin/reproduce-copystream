#!/usr/bin/env ruby

require "minitest/autorun"
require "minitest/pride"
require 'tempfile'

class TestIOCopyStream < MiniTest::Unit::TestCase

  def check_copied_bytes(original_file_path, src, dst = Tempfile.new())
    original_file_size = File.new(original_file_path).size
    assert_equal original_file_size, src.size # this is true in all cases
    copied_bytes_count = IO.copy_stream(src, dst)
    assert_equal original_file_size, copied_bytes_count # this fails only on tempfiles lastly copied from mounted files. AND only with some docker env. 
  end

  def test_ok_open_local_png
    original_file_path = './example.png'
    src = File.open(original_file_path)
    check_copied_bytes(original_file_path, src)
  end

  def test_ok_open_mounted_png
    original_file_path = '/mnt/example.png'
    src = File.open(original_file_path)
    check_copied_bytes(original_file_path, src)
  end

  def test_ok_tempfile_copy_png_file_local
    original_file_path = './example.png'
    src = Tempfile.new()
    src.set_encoding(Encoding::BINARY)
    FileUtils.copy_file('./example.png', src.path)
    check_copied_bytes(original_file_path, src)
  end

  # FIXME
  def test_fail_on_tempfile_lastly_copied_from_png_file_mounted
    original_file_path = '/mnt/example.png'
    src = Tempfile.new()
    src.set_encoding(Encoding::BINARY)
    FileUtils.copy_file(original_file_path, src.path)
    check_copied_bytes(original_file_path, src)
  end

  # FIXME
  def test_fail_on_tempfile_lastly_copied_from_txt_file_mounted
    original_file_path = '/mnt/example.txt'
    src = Tempfile.new()
    FileUtils.copy_file(original_file_path, src.path)
    check_copied_bytes(original_file_path, src)
  end

  # FIXME
  def test_not_fixed_with_tempfile_even_after_rewind
    original_file_path = '/mnt/example.png'
    src = Tempfile.new(['example', '.png'])
    src.set_encoding(Encoding::BINARY)
    FileUtils.copy_file(original_file_path, src.path)
    src.rewind
    check_copied_bytes(original_file_path, src)
  end

  def test_fixed_as_soon_as_utime_is_made_after_copy_file_mounted
    original_file_path = '/mnt/example.png'
    src = Tempfile.new(['example', '.png'])
    src.set_encoding(Encoding::BINARY)
    FileUtils.copy_file(original_file_path, src.path)
    File.utime src.atime, src.mtime, src.path
    check_copied_bytes(original_file_path, src)
  end

  def test_fixed_as_soon_as_noop_chmod_is_made_after_tempfile_copy_file_mounted
    original_file_path = '/mnt/example.png'
    src = Tempfile.new(['example', '.png'])
    src.set_encoding(Encoding::BINARY)
    FileUtils.copy_file(original_file_path, src.path)
    src.chmod src.lstat.mode
    check_copied_bytes(original_file_path, src)
  end
end