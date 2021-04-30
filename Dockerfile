FROM ruby:2.6.6

COPY example.png ./
COPY example.txt ./

COPY repro.rb ./

# CMD ["ruby", "repro.rb"]

CMD ruby -Ilib:test mnt/test.rb