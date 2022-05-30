#!/usr/bin/env ruby

require 'json'
class Ngram
  DEFAULT_REGEXP = %r|[\=\/\w\,\.\-\'\!\?\;\:]+|.freeze # look for the words
  # FIXME, when reading from the bible, I want to keep the reference to the source:
  # i.e. book, chapter, and verse for each token
  DEFAULT_NUM_NGRAMS = 3
  def initialize(json_bible_path, size: nil, regexp: nil, trim_and_lower: true, token_ref_path: nil)
    @size      = size || DEFAULT_NUM_NGRAMS
    @regexp    = regexp || DEFAULT_REGEXP
    @json_bible_path = json_bible_path
    @token_ref_path  = token_ref_path
    @trim            = trim_and_lower
    @lower           = trim_and_lower
  end

  def save(path=nil)
    unless File.exist?(@json_bible_path)
      warn("Missing json_bible_path")
      return false
    end
    path ||= "index_#{@size}_#{@json_bible_path}"
    File.open(path, "w") { |f| f.puts to_s } && path
  end

  def trim_punct(tok)
    if @trim && tok
      # any punct followed by a space:
      return @lower ? tok.gsub(/[[:punct:]](\s+|$)/,'\1').downcase : tok.gsub(/[[:punct:]](\s+|$)/,'\1')
    end
    return tok
  end

  def token_reference
    unless @token_reference
      if @token_ref_path && File.exist?(@token_ref_path)
        @token_reference = JSON.parse(File.read(@token_ref_path))
      else
      fail("Unknown file #{@json_bible_path}") unless File.exist?(@json_bible_path)
      # {"passage":"Now the word of the LORD came to Jonah the second time, saying,","book":"Jonah","verse":1,"chapter":3}

      @token_reference = {}
      prev_line = nil
      File.readlines(@json_bible_path).each { |line|
        begin
        hash = JSON.parse(line)
        rescue Exception => e
          warn("JSON issue w/ line: #{line.inspect}; following: #{prev_line.inspect}")
        end
        source = hash.slice("book","chapter","verse")
        # this could get too big for memory ?!
        sort_order = 0
        @token_reference = hash["passage"].scan(@regexp).map {|tok| trim_punct(tok) }.each_cons(@size).to_a.reduce(@token_reference) {|m, ngram|
          sort_order += 1
          ngram_str = ngram.join(' ')
          # #FAIL cuz the same word is used in multiple places!
          # USE an array of sources...
          m[ngram_str] ||= []
          m[ngram_str] << {"sort_order" => sort_order}.merge(source)
          m[ngram_str].sort {|a,b| [a["book"], a["chapter"], a["verse"], a["sort_order"]] <=> [b["book"], b["chapter"], b["verse"], b["sort_order"]]} # slow cuz it happens each loop
          m
        } # reduce
        prev_line = line
      } # line
      # sort by sort_order
      end # if-else-end
    end
    @token_reference
  end

  def to_s
    # to_h.to_json
    json(to_h, true)
  end

  def json(arg, per_line=false)
    case arg
      when String
        #warn("String case...")
        %Q|"#{arg}"|
      when Array
        #warn("Array case: #{arg.inspect}")
        "[" + arg.map {|e| json(e)}.join(", ") + "]"
      when Hash
        #warn("Hash case...")
        if per_line
          "{\n" + arg.map{ |k,v| "#{json(k)}: #{json(v)}" }.join(",\n") + "\n}"
        else
          "{" + arg.map{ |k,v| "#{json(k)}: #{json(v)}" }.join(", ") + "}"
        end
      else
        #warn("ELSE arg.class: #{arg.class}")
        arg
    end
  end

  # loses direct connection to source
  # but the lookup table (@token_reference) exists...
  def to_h
    unless @to_h
      # m[ngram_str] << {sort_order: sort_order}.merge(source)
      #@to_h = token_reference.sort.to_h
      @to_h = token_reference.to_h
    end
    @to_h
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.size < 1
    fail(%Q|Missing path to json formatted bible: on entry-per line: {"book":...,"chapter":...,"verse":...,"passage":...}|)
  end
  token_ref_path = nil
  bible_path     = ARGV[0]
  if "--token_ref_path" == bible_path
    if ARGV.size < 1
      fail(%Q|--token_ref_path value missing|)
    end
    token_ref_path = ARGV.shift
    bible_path     = nil
  end
  ngram_size = nil
  if ARGV.size < 2
    warn("Resorting to default size of ngrams: #{Ngram::DEFAULT_NUM_NGRAMS}")
  else
    ngram_size = ARGV[1].to_i
  end
  ng = Ngram.new(bible_path, size: ngram_size, token_ref_path: token_ref_path)
  if token_ref_path # && File.exist?(token_ref_path)
    puts(ng.to_s)
  else
    puts(ng.save)
  end
end
