Yokozuna and EC2
----------

## Building a Cluster

### Open HTTP to Outside

To use Riak/Yokozuna from outside port `8098` must be opened.

    ec2-authorize default -p 8098

### Allow Inter-node Communication

Riak relies on distributed Erlang for intercommunication.  Distributed
Erlang relies on port `4369` along with a range of dynamic ports.  The
simplest solution is to enable traffic across all ports among the EC2
instances.

    ec2-authorize default -P TCP -p -1 -o default

### Start Instances

I recommend [using five nodes][five_nodes].  If you just want to
experiment one node will work.  [Performance Tuning for AWS][perf_aws]
contains advice in regards to running Riak on EC2.

    ec2-run-instances ami-8d9c20e4 -k <YOUR_KEY> -n <NUM_NODES>

Each instance contains a self-contained Riak release under
`~ec2-user/riak/rel/riak`.  Many of the following sections assume a
remote shell on each instance with a working directory of
`~ec2-user/riak/rel/riak`.

### Modify vm.args

The node name in the `etc/vm.args` file must be changed _before_
starting Riak.

    -name riak@<HOSTNAME>

Change the cookie for extra security.  This isn't strictly necessary
but if the distributed Erlang ports are open to the outside world then
you should change the cookie to prevent outside access to your Erlang
cluster.

    -cookie <SOME_TEXT>

### Increase nofile (ulimit -n)

This next step is convoluted because of how sysctl and ulimit work.
The next AMI will raise the limit for you automatically.

First edit `/etc/security/limits.conf` to up the open file limit for
`ec2-user`.

    sudo vim /etc/security/limits.conf

Add the following line.

    ec2-user hard nofile 50000

Start a new login shell under ec2-user.  Make sure to start Riak in
this session.

    sudo su - ec2-user

Set the open file limit.

    ulimit -n 50000

**NOTE: This step needs to be done _every time_ Riak is started.**

### Start Riak

    ./bin/riak start

### Form a Cluster

Yokozuna is an addition to Riak.  [Building a cluster][cluster_setup]
is the same as Riak.  There are no additional steps introduced by
Yokozuna.

    ./bin/riak-admin cluster join riak@<FIRST_INSTNACE_HOSTNAME>

    ./bin/riak-admin cluster plan

    ./bin/riak-admin cluster commit

### Index/Query Data

To start indexing and querying data take a look at the
[Getting Started] [gs] guide.  At the moment there is only support for
`text/plain` and `text/xml` content types.  More thorough docs on
indexing coming soon.

## The AMI

The AMI is a customization of Amazon Linux ami-8d9c20e4.  It
is x86_64 using instance storage.

    $ ec2-describe-images ami-8d9c20e4
    IMAGE   ami-8d9c20e4    682127949672/yokozuna_ami       682127949672    available       public          x86_64  machine aki-88aa75e1                    instance-store  paravirtual     xen

Yokozuna is a moving target.  If you run into issues you may want to
check which commit of Yokozuna is being used and compare it against
the [commit log] [yz_commit_log].

    $ (cd ~ec2-user/riak/deps/yokozuna && git log -1)


[cluster_setup]: http://docs.basho.com/riak/latest/cookbooks/Basic-Cluster-Setup/

[five_nodes]: http://basho.com/blog/technical/2012/04/27/Why-Your-Riak-Cluster-Should-Have-At-Least-Five-Nodes/

[gs]: https://github.com/rzezeski/yokozuna#creating-an-index

[perf_aws]: http://docs.basho.com/riak/latest/cookbooks/Performance-Tuning-AWS/

[yz_commit_log]: https://github.com/rzezeski/yokozuna/commits/master
