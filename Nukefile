;; source files
(set @m_files     (filelist "^Framework/Pantomime/.*.m$"))
(set @c_files     (filelist "^Framework/Pantomime/.*.c$"))

(set @arch (list "x86_64"))
(set @cflags "-I . -g -std=gnu99 -fobjc-gc -DDARWIN -DMACOSX")
(set @ldflags  "-framework Foundation -framework Nu -lssl -lcrypto")

;; framework description
(set @framework "Pantomime")
(set @framework_identifier "nu.programming.pantomime")
(set @framework_creator_code "????")
(set @public_headers (filelist "^Framework/Pantomime/.*\.h$"))

(compilation-tasks)
(framework-tasks)

(task "clobber" => "clean" is
      (SH "rm -rf #{@framework_dir}"))

(task "default" => "framework")

(task "doc" is (SH "nudoc"))

