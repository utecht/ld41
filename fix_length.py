wordlist = open('wwf.txt', 'r')
output = open('small_words.txt', 'w')
for word in wordlist:
    length = len(word.strip())
    if length > 2 and length < 6:
        output.write(word)
