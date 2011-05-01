a=(pixels1 pixels2 pixels3 dummy)
for n in ${a[@]}
do
	echo $n
	convert $n.png rgb:$n.raw
	cat $n.raw | python bin2h.py $n > $n.h
done
