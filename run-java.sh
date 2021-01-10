[ -z "$TMPDIR" ] && TMPDIR=$(pwd)/.tmp
export TMPDIR=$TMPDIR
mkdir -p "$TMPDIR"

JAVA_HEAP_MAX=-Xmx25g
JAVA_STACK_TRACE="-XX:OnOutOfMemoryError=\"kill -9 %p\""
JAVA_TMP_DIR="-Djava.io.tmpdir=$TMPDIR"

JAVA_OPTIONS="$JAVA_STACK_TRACE $JAVA_TMP_DIR $JAVA_HEAP_MAX"
#CLASS_PATH=$JAVA_HOME/lib/*:$lib_project/*:$MAIN_JAR

until java "$JAVA_OPTIONS" -jar "$@"; do
  echo "Application crashed with exit code $?. Respawning... " >&2
  sleep 5
done
