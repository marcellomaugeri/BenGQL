```
docker build --platform=linux/amd64 -t timbuctoo .
docker run --rm -it -p12000:8080 timbuctoo:latest
```


This server is based on GraphQL-Java. It seems that the introspection can be disabled in different ways, but have not tried:
[Link 1](https://stackoverflow.com/questions/72125480/how-to-disbale-introspection-query-in-graphql-java)
[Link 2](https://stackoverflow.com/questions/64882196/disable-graphql-introspection-in-graphql-java-tools)

The schema should be create in `timbuctoo/src/main/java/nl/knaw/huygens/timbuctoo/dropwizard/endpoints/GraphQl.java` line 168