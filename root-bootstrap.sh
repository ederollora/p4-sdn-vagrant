#!/bin/bash
set -xe

# Create user sdn 
:
useradd -m -d /home/sdn -s /bin/bash sdn
echo "sdn:rocks" | chpasswd
echo "sdn ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_sdn
chmod 440 /etc/sudoers.d/99_sdn
usermod -aG vboxsf sdn
update-locale LC_ALL="en_US.UTF-8"

# Java 8, ONOS required
apt-get install software-properties-common -y
add-apt-repository ppa:webupd8team/java -y
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections


apt-get -y --no-install-recommends install \
    avahi-daemon \
    curl \
    bridge-utils \
    emacs \
    git \
    git-review \
    htop \
    nano \
    ntp \
    oracle-java8-installer \
    oracle-java8-set-default \
    python2.7 \
    python2.7-dev \
    tcpdump \
    unzip \
    valgrind \
    vim \
    vlan \
    zip \


curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python2.7 get-pip.py --force-reinstall
rm -f get-pip.py

tee -a /etc/ssh/sshd_config <<EOF

UseDNS no
EOF

#Apache Karaf & MAVEN
su sdn <<'EOF'

cd ~
mkdir -p Downloads Applications
cd Downloads
wget http://archive.apache.org/dist/karaf/3.0.5/apache-karaf-3.0.5.tar.gz
wget http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -zxvf apache-karaf-3.0.5.tar.gz -C ../Applications/
tar -zxvf apache-maven-3.3.9-bin.tar.gz -C ../Applications/
EOF

su sdn <<'EOF'
cd /home/sdn
bash /vagrant/sim-bootstrap.sh
EOF

su sdn <<'EOF'
cd /home/sdn
bash /vagrant/p4-bootstrap.sh
EOF

su sdn <<'EOF'
cd /home/sdn
bash /vagrant/apps-bootstrap.sh
EOF

su sdn <<'EOF'
cd /home/sdn
echo 'bash ~/custom-commands.sh' >> ~/.bashrc
cp /vagrant/custom-commands.sh ~/custom-commands.sh
EOF
