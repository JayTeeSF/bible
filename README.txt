cat NASB.json | jq -c '.[]' | grep '"book":"Jonah"' > jonah.json
cat jonah.json | wc -l
#      48
grep '"chapter":1' jonah.json > jonah_1.json
grep '"chapter":2' jonah.json > jonah_2.json
grep '"chapter":3' jonah.json > jonah_3.json
grep '"chapter":4' jonah.json > jonah_4.json

count verses by chapter:
  cat jonah_1.json  | wc -l # 17
  cat jonah_2.json  | wc -l # 10
  cat jonah_3.json  | wc -l # 10
  cat jonah_4.json  | wc -l # 11

extract passage-text from a chapter:
cat jonah_3.json | jq  -c '.|.passage' | awk '{ print substr( $0, 2, length($0)-2 ) }' | tr -d "\\" > jonah_3_passages.json 
trigrams:
cd ../word_gram_sentence/
./ngram.rb ../bible/jonah_3_passages.json 3 > ../bible/jonah_3_trigrams.txt

unigrams:
cd ../word_gram_sentence/
./ngram.rb ../bible/jonah_3_passages.json > ../bible/jonah_3_unigrams.txt

run-length encode the unigrams (ignore ending-punctuation):
./run_length_encode.rb jonah_3_unigrams.txt > jonah_3_rle_unigrams.txt
./run_length_encode.rb jonah_3_unigrams.txt 1 |json_pp > jonah_3_rle_unigrams.json


run-length encode the trigrams (ignore ending-punctuation):
./run_length_encode.rb jonah_3_trigrams.txt > jonah_3_rle_trigrams.txt

./word_index.rb jonah_1.json > jonah_1_index.json

####

↪ wc -l line_per_verse_nasb.json
   31102 line_per_verse_nasb.json
(base) ¿jthomas? ~/dev/bible_fun[master*]
↪ ./word_index.rb line_per_verse_nasb.json > nasb_index.json
starting w/ file "line_per_verse_nasb.json"...
found 16897 words in the index


grab a book:
  cat NASB.json | jq -c '.[]' | grep '"book":"Philippians"' > philippians.json

count total verses:
  cat philippians.json  | wc -l # 104

grab a chapter:
  grep '"chapter":1' philippians.json > philippians_1.json
  grep '"chapter":2' philippians.json > philippians_2.json
  grep '"chapter":3' philippians.json > philippians_3.json
  grep '"chapter":4' philippians.json > philippians_4.json

count verses by chapter:
  cat philippians_1.json  | wc -l # 30
  cat philippians_2.json  | wc -l # 30
  cat philippians_3.json  | wc -l # 21
  cat philippians_4.json  | wc -l # 23

extract unique words for analysis:
↪ ./word_index.rb philippians.json > philippians_index.json
starting w/ file "philippians.json"...
found 592 words in the index

total unique words:
  cat philippians_index.json  | jq -c '.[]' | wc -l # 592

↪ ./word_index.rb philippians_1.json > philippians_1_index.json
starting w/ file "philippians_1.json"...
found 243 words in the index

↪ ./word_index.rb philippians_2.json > philippians_2_index.json
starting w/ file "philippians_2.json"...
found 251 words in the index

↪ ./word_index.rb philippians_3.json > philippians_3_index.json
starting w/ file "philippians_3.json"...
found 207 words in the index

↪ ./word_index.rb philippians_4.json > philippians_4_index.json
starting w/ file "philippians_4.json"...
found 217 words in the index

Extract just the passage (including JSON key, though):
cat philippians_2.json | jq  -c '.|{passage}' # ....; {"passage":"holding fast the word of lif...}; ....

Just the passage values (quoted):
cat philippians_2.json | jq  -c '.|.passage' # ....; "holding fast the word of life..."; ....

remove starting and ending quotes with awk:
cat philippians_2.json | jq  -c '.|.passage' | awk '{ print substr( $0, 2, length($0)-2 ) }'
