# frozen_string_literal: true

require 'ffi'
require 'rbconfig'

module Sys
  class Filesystem
    module Structs
      # The Statfs struct is a subclass of FFI::Struct that corresponds to a struct statfs.
      class Statfs < FFI::Struct
        # Private method that will determine the layout of the struct on Linux.
        def self.linux64?
          if RUBY_PLATFORM == 'java'
            ENV_JAVA['sun.arch.data.model'].to_i == 64
          else
            RbConfig::CONFIG['host_os'] =~ /linux/i &&
              (RbConfig::CONFIG['arch'] =~ /64/ || RbConfig::CONFIG['DEFS'] =~ /64/)
          end
        end

        private_class_method :linux64?

        # FreeBSD 12.0 MNAMELEN from 88 => 1024.
        MNAMELEN =
          if RbConfig::CONFIG['host_os'] =~ /freebsd(.*)/i
            Regexp.last_match(1).to_f < 12.0 ? 88 : 1024
          else
            88
          end

        case RbConfig::CONFIG['host_os']
          when /bsd/i
            layout(
              :f_version, :uint32,
              :f_type, :uint32,
              :f_flags, :uint64,
              :f_bsize, :uint64,
              :f_iosize, :int64,
              :f_blocks, :uint64,
              :f_bfree, :uint64,
              :f_bavail, :int64,
              :f_files, :uint64,
              :f_ffree, :uint64,
              :f_syncwrites, :uint64,
              :f_asyncwrites, :uint64,
              :f_syncreads, :uint64,
              :f_asyncreads, :uint64,
              :f_spare, [:uint64, 10],
              :f_namemax, :uint32,
              :f_owner, :int32,
              :f_fsid,  [:int32, 2],
              :f_charspare, [:char, 80],
              :f_fstypename, [:char, 16],
              :f_mntfromname, [:char, MNAMELEN],
              :f_mntonname, [:char, MNAMELEN]
            )
          when /linux/i
            if linux64?
              layout(
                :f_type, :ulong,
                :f_bsize, :ulong,
                :f_blocks, :uint64,
                :f_bfree, :uint64,
                :f_bavail, :uint64,
                :f_files, :uint64,
                :f_ffree, :uint64,
                :f_fsid, [:int, 2],
                :f_namelen, :ulong,
                :f_frsize, :ulong,
                :f_flags, :ulong,
                :f_spare, [:ulong, 4]
              )
            else
              layout(
                :f_type, :ulong,
                :f_bsize, :ulong,
                :f_blocks, :uint32,
                :f_bfree, :uint32,
                :f_bavail, :uint32,
                :f_files, :uint32,
                :f_ffree, :uint32,
                :f_fsid, [:int, 2],
                :f_namelen, :ulong,
                :f_frsize, :ulong,
                :f_flags, :ulong,
                :f_spare, [:ulong, 4]
              )
            end
          else
            layout(
              :f_bsize, :uint32,
              :f_iosize, :int32,
              :f_blocks, :uint64,
              :f_bfree, :uint64,
              :f_bavail, :uint64,
              :f_files, :uint64,
              :f_ffree, :uint64,
              :f_fsid, [:int32, 2],
              :f_owner, :int32,
              :f_type, :uint32,
              :f_flags, :uint32,
              :f_fssubtype, :uint32,
              :f_fstypename, [:char, 16],
              :f_mntonname, [:char, 1024],
              :f_mntfromname, [:char, 1024],
              :f_reserved, [:uint32, 8]
            )
        end
      end

      # The Statvfs struct represents struct statvfs from sys/statvfs.h.
      class Statvfs < FFI::Struct
        # Private method that will determine the layout of the struct on Linux.
        def self.linux64?
          if RUBY_PLATFORM == 'java'
            ENV_JAVA['sun.arch.data.model'].to_i == 64
          else
            RbConfig::CONFIG['host_os'] =~ /linux/i &&
              (RbConfig::CONFIG['arch'] =~ /64/ || RbConfig::CONFIG['DEFS'] =~ /64/)
          end
        end

        if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach/i
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint,
            :f_bfree, :uint,
            :f_bavail, :uint,
            :f_files, :uint,
            :f_ffree, :uint,
            :f_favail, :uint,
            :f_fsid, :ulong,
            :f_flag, :ulong,
            :f_namemax, :ulong
          )
        elsif RbConfig::CONFIG['host'] =~ /bsd/i
          layout(
            :f_bavail, :uint64,
            :f_bfree, :uint64,
            :f_blocks, :uint64,
            :f_favail, :uint64,
            :f_ffree, :uint64,
            :f_files, :uint64,
            :f_bsize, :ulong,
            :f_flag, :ulong,
            :f_frsize, :ulong,
            :f_fsid, :ulong,
            :f_namemax, :ulong
          )
        elsif !linux64?
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint,
            :f_bfree, :uint,
            :f_bavail, :uint,
            :f_files, :uint,
            :f_ffree, :uint,
            :f_favail, :uint,
            :f_fsid, :ulong,
            :f_unused, :int,
            :f_flag, :ulong,
            :f_namemax, :ulong,
            :f_spare, [:int, 6]
          )
        else
          layout(
            :f_bsize, :ulong,
            :f_frsize, :ulong,
            :f_blocks, :uint64,
            :f_bfree, :uint64,
            :f_bavail, :uint64,
            :f_files, :uint64,
            :f_ffree, :uint64,
            :f_favail, :uint64,
            :f_fsid, :ulong,
            :f_flag, :ulong,
            :f_namemax, :ulong,
            :f_spare, [:int, 6]
          )
        end
      end

      # The Mntent struct represents struct mntent from sys/mount.h on Unix.
      class Mntent < FFI::Struct
        layout(
          :mnt_fsname, :string,
          :mnt_dir, :string,
          :mnt_type, :string,
          :mnt_opts, :string,
          :mnt_freq, :int,
          :mnt_passno, :int
        )
      end
    end
  end
end
