function sub = subscript(text)

sub = [];
for c = text
    sub = [sub, '_' c];
end