FROM tinkerpop/gremlin-server:3.5.3

RUN rm -rf /opt/gremlin-server/ext/tinkergraph-gremlin

ADD tinkergraph-gremlin /opt/gremlin-server/ext/tinkergraph-gremlin

ADD tinkergraph-empty.properties /opt/gremlin-server/conf/
