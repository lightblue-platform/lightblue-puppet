#!/bin/sh

#  hiera::key::name:
#    datatype: String.
#    description: |
#      String describing the key.
#    found_in:
#    - someFile.yaml

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

PATTERN_PARAM=\[[*]\([^*]*\)[*]\]
PATTERN_COMMENT=\(.+\)

HIERA_DIR=../hieradata

for file in `git grep -l class manifests/ | sort`;
do

    CLASS=`grep class $file | awk '{print $2}'`
    PARAM=""
    DOCS=""

    # look only at comments that begin a line.  strip off the leading # and spaces for simplification
    for line in `cat $file | grep ^# | sed 's/^#[ ]*//g'` ;
    do
        if [[ $line =~ $PATTERN_PARAM ]] ;
        then
            if [ "$PARAM" != "" ] ;
            then
                # remove leading white space and double periods (anywhere)
                DOCS=`echo $DOCS | sed 's/^[\t .]*//g' | sed 's/\.\././g'`
                echo "${PARAM}-A#  ${PARAM}:"
                echo "${PARAM}-B#    datatype: String."
                if [ "$DOCS" != "" ];
                then
                    echo "${PARAM}-C#    description: |"
                    echo "${PARAM}-D#      ${DOCS}"
                fi

                if [[ `grep -Rl $PARAM $HIERA_DIR | egrep -v -e \.git -e README.md -e definitions.yaml | wc -l` > 0 ]];
                then
                    echo "${PARAM}-E#    found_in:"
                    for found in `grep -Rl $PARAM $HIERA_DIR | egrep -v -e \.git -e README.md -e definitions.yaml | sed "s#$HIERA_DIR\/##g"`;
                    do
                        echo "${PARAM}-F#    - ${found}"
                    done
                fi
            fi
            # this is a param definition, get the name and reset docs
            PARAM="${CLASS}::${BASH_REMATCH[1]}"
            DOCS=
        elif [[ $line =~ $PATTERN_COMMENT ]] ;
        then
            # this is documentation, capture it
            DOCS="${DOCS}. ${BASH_REMATCH[1]}"
        fi
    done
done

IFS=$SAVEIFS
