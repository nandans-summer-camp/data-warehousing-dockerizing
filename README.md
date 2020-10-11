# Dockerizing Applications

You have a new assignment from your boss at Foo's Models. She's very worried that some customers are getting to cozy with her sales staff and getting deep discounts. She wants a command line tool that she can run every morning to give her an answer to the following question: 

- Which customers (by name) are getting at least 75% of their orders at 10%+ discount over MSRP.

Her computer is usually a mess, but you know that she has a working installation of Docker. Your job is to: 

1. Run your data warehouse on an AWS instance and make it publically available so that it can be connected to from anywhere. 

2. Make a Docker image that can connect to your warehouse and run the query necessary to answer your boss's question. 

3. Send me the command that your boss will need to run from her terminal in order to get the answer she wants. 

4. Follow best practices such that no secret information (passwords, usernames, maybe also IP addresses) is hardcoded in the Docker image itself, but rather is passed in the command that your boss runs via the command line.

5. Submit the assignment by writing the command in Google Classroom (remember: the command contains secrets, so don't let them get into Git!)

You might want to read the [tutorial.md](tutorial.md) to learn a bit more about how to Dockerize an application. Note: in the tutorial you will Dockerize a Python app that connects to Mongo. For this project you could similarly make a Python app that connects to Postgres OR you could try and make an app that uses the Postgres image and runs psql with a query in the container, skipping Python altogether. Both are interesting exercises, so pick one or try both!
