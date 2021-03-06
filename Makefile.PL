use inc::Module::Install;
name 'Log-Dispatch-Email-EmailSender';
all_from 'lib/Log/Dispatch/Email/EmailSender.pm';
readme_from 'lib/Log/Dispatch/Email/EmailSender.pm';
readme_markdown_from 'lib/Log/Dispatch/Email/EmailSender.pm';
readme_pod_from 'lib/Log/Dispatch/Email/EmailSender.pm';
githubmeta;

requires 'Log::Dispatch';
requires 'Encode';
requires 'Email::MIME';
requires 'Email::Sender::Simple';
requires 'Email::Sender::Transport::SMTP';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
