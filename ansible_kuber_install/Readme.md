# Инсталяция K8s на ноды Proxmox
Для инсталяции будем исполтьзовать данную роль, а именно сначала установим отдельно containerd, проверим данную конфигурация.
В дальнейшем возможно ошибка при init, необходимо проверить 

    /etc/containerd/config.toml 
    SystemdCgroup = true
После инсталяции необходимо проверить kubelet, status возможно swapoff -a отработал не корректно и необходимо закрыть строчку в 

    /etc/fstab
    #/swap.img      none    swap    sw      0       0

Далее необходимо сделать reboot

Далее необходимо проинсталить Calico:

1. Инициализируйте мастер с помощью следующей команды.

        sudo kubeadm init --pod-network-cidr=192.168.0.0/16

2. Далее необходимо закинуть конфиг в home directory

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

3. Установите оператор Tigera Calico 

        kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml

4. Установите Calico

        kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml


4. Подтвердите, что все модули работают, с помощью следующей команды.

        watch kubectl get pods -n calico-system

5. Удалите дефекты на мастере, чтобы вы могли планировать на нем модули.

        kubectl taint nodes --all node-role.kubernetes.io/control-plane-
        kubectl taint nodes --all node-role.kubernetes.io/master-
6. Подтвердите, что теперь у вас есть узел в вашем кластере

        kubectl get nodes -o wide

Для инициализации на worker nodax

    kubeadm join 192.168.88.50:6443 --token jcph87.kwy3sn3yeqnu791c \
        --discovery-token-ca-cert-hash sha256:e786f1dfa6c3f5abcab8d6e08914ee4bc0d63698d83ed72f464ce4c65b7ccbbc

дополнительные команды

        kubectl get pods --all-namespaces

Для отображения узлов 

    kubectl get nodes

Увидеть текущий список всех доступных сервисов

    kubectl get svc

    kubectl cluster-info

    kubectl config view

https://medium.com/@owibdw/install-kubernetes-cluster-on-ubuntu-22-04-lts-83cef904e848 </br>
https://docs.tigera.io/calico/3.25/getting-started/kubernetes/quickstart </br>
Список возможных ошибок </br>
https://jhooq.com/amp/kubernetes-error-execution-phase-preflight-preflight/


Удаление всех POD 

    kubectl delete pod --all

Запускаем команду 

    kubectl apply -f ./k8s/2.replicaset.yml 
Проверяем

    kubectl get pod
    NAME          READY   STATUS    RESTARTS   AGE
    myapp-87nj2   1/1     Running   0          30s
    myapp-dgvvk   1/1     Running   0          30s

    kubectl get replicaset
    NAME    DESIRED   CURRENT   READY   AGE
    myapp   2         2         2       2m10

    kubectl edit replicaset myapp

Для просмотра информации о контайнере

    kubectl describe replicaset myapp
    Name:         myapp
    Namespace:    default
    Selector:     app=mya

    kubectl describe pod myapp-87nj2
    Name:             myapp-87nj2
    Namespace:        default

Для обновления image внутри контейнера(при рестарте)

    kubectl set image replicaset myapp myapp=nginx:1.17
    *****то что обновляем(image) name replica and name containers

Нужно будет пересоздать pod

    kubectl get rs (replica set)
    kubectl get po (replica set create pod)
    kubectl get deployments.apps

Вернуться к предыдущей версии 

    kubectl rollout undo deployment (name deployment)* (--to-revision=(0 предыдущая))
*данная комманда применима только к деплойменту

Отслеживать состояние в реальном времени 
    kubectl get po -w

Команда для доп анализа 
  kubectl describe deployments.apps mydeploy

Для входа в pod

    kubectl exec -it mydeploy-b788f9b67-km5ls bash

secret
  kubectl create secret generic test --from-literal=test1=asdf
  kubextl get secret
  kubectl get secret test -o yaml
  echo test | base64 -d

service

    kubectl get service
    kubectl get ep

Посмотреть все поды с метками

    kubectl get pod --show-labels

Посмотреть информацию о pod
    kubectl get pod -o wide

Если ошибки

    kubectl -n dev  get pod mydeploy-b788f9b67-kxq8g -o yaml
    kubectl -n dev  describe pod mydeploy-b788f9b67-kxq8g

Для рестарта 

    kubectl scale deployment demo-deployment --replicas=0
    kubectl scale deployment demo-deployment --replicas=1 