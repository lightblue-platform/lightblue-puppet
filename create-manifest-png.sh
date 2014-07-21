#!/bin/sh

pushd manifests/ > /dev/null

DEFINE_LIST=`git grep lightblue:: | sed 's/.*\.pp://g' | grep "^define"|
sed "s/define[ ]*\([^ ({]*\).*/\1/g"|
sort | uniq`
CLASS_LIST=`git grep lightblue:: | sed 's/.*\.pp://g' | grep "^class"|
sed "s/class[ ]*\([^ ({]*\).*/\1/g"|
sort | uniq`

echo "digraph {
$(for x in $CLASS_LIST
do
    KEY=`echo $x|tr ':' '_'`
    echo "$KEY [label=\"$x\"];"
done
)

$(for x in $DEFINE_LIST
do
    KEY=`echo $x|tr ':' '_'`
    echo "$KEY [label=\"$x\"];"
done
)

`git grep lightblue:: |grep -v ":#" | grep -v define|egrep -e "include lightblue" -e "class[ ]*{[ ]*'lightblue" -e "inherits" -e "lightblue::jcliff::config"|
sed "s/include//g"|
sed "s/inherits//g"|
sed "s/class[ ]*{[ ]*'\([^']*\)'.*/\1/g"|
sed "s/\(.*\)\.pp:[ ]*\(lightblue[A-Za-z:_]*\).*/lightblue::\1 -> \2;/g"|sed 's#/#::#g'|
sed "s/:/_/g"
`
}" > ../lightblue.dot

popd > /dev/null

dot -Tpng -o lightblue.png lightblue.dot
