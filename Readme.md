# Практика от Яндекс
## Настройка среды для работы
В начале требуется происталить необходимые пакеты.
Прикреплю ссылки </br>
1) install kubectl </br>
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ </br>
2) install helm </br>
https://helm.sh/docs/intro/install/ </br>
3) Установка cli для яндекс-облака в данном случае </br>
https://cloud.yandex.com/en/docs/cli/operations/install-cli </br>
4) Для иниициализации yc </br>
https://cloud.yandex.ru/docs/cli/quickstart#initialize </br>

Далее необходимо сделать настройки с помощью терраформа </br>

        terraform init обновим нашего провайдера на новую версию
        terraform validate
        Success! The configuration is valid.

Далее проверяем plan и apply

        terraform plan
        terraform apply
Для удаления используется

        terraform destroy
Сохраню примеры команд для yc

        yc vpc security-group create --name yc-security-group --network-name default \
        --rule 'direction=ingress,port=443,protocol=tcp,v4-cidrs=0.0.0.0/0' \
        --rule 'direction=ingress,port=80,protocol=tcp,v4-cidrs=0.0.0.0/0' \
        --rule 'direction=ingress,from-port=0,to-port=65535,protocol=any,predefined=self_security_group' \
        --rule 'direction=ingress,from-port=0,to-port=65535,protocol=any,v4-cidrs=[10.96.0.0/16,10.112.0.0/16]' \
        --rule 'direction=ingress,from-port=0,to-port=65535,protocol=tcp,v4-cidrs=[198.18.235.0/24,198.18.248.0/24]' \
        --rule 'direction=egress,from-port=0,to-port=65535,protocol=any,v4-cidrs=0.0.0.0/0' \
        --rule 'direction=ingress,protocol=icmp,v4-cidrs=[10.0.0.0/8,192.168.0.0/16,172.16.0.0/12]' 
После всех манипуляций с терраформом 

        yc managed-kubernetes cluster get-credentials --name=kube-infra --external

        Context 'yc-cluster' was added as default to kubeconfig '/home/mikhail/.kube/config'.
        Check connection to cluster using 'kubectl cluster-info --kubeconfig /home/mikhail/.kube/config'.

        Note, that authentication depends on 'yc' and its config profile 'default'.
        To access clusters using the Kubernetes API, please use Kubernetes Service Account.
        terraform $ kubectl get nodes                                         
        NAME                        STATUS   ROLES    AGE     VERSION
        cl10r3n9mjtc7jnduove-itec   Ready    <none>   2m38s   v1.22.6

        kubectl get node -o wide    
        NAME                        STATUS   ROLES    AGE    VERSION   INTERNAL-IP    EXTERNAL-IP     OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
        cl10r3n9mjtc7jnduove-itec   Ready    <none>   6m5s   v1.22.6   192.168.0.22   62.84.119.211   Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.7

### Полезные команды kubectl

         yc managed-kubernetes node-group list
         kubectl cluster-info 

        kubectl cheatsheet
        Полезные команды kubectl, которые могут пригодиться при работы с кластером:
        kubectl apply -f — применить манифесты
        kubectl get <kind> — получить список объектов <kind>
        kubectl get <kind> <name> -o wide — выдает больше информации, в зависимости от kind
        kubectl get <kind> <name> -o yaml — в виде yaml
        kubectl describe <kind> <name> — текстовое описание + события
        kubectl edit — редактирование прямо в терминале любого ресурса
        kubectl logs <pod_name> — посмотреть логи пода
        kubectl port-forward — пробросить порт из Kubernetes на локальный хост
        kubectl exec — выполнить команду внутри запущенного контейнера

К сожалению терраформ не может вытащить json и блок формирования ключа мне не помог

        resource "yandex_iam_service_account_key" "sa-auth-key" {
        service_account_id = "${yandex_iam_service_account.ingress.id}"
        key_algorithm      = "RSA_4096"
        }

Решение не найденно....</br> Возможно будет найден другой формат взаимиодейстия, используя баш-скрипты.
Воспользуюсь командой. которой предоставляет yc

        yc iam key create --service-account-name ingress-controller --output sa-key.json
Авторизуемся в Yandex helm registry:

        export HELM_EXPERIMENTAL_OCI=1
        cat sa-key.json | helm registry login cr.yandex --username 'json_key' --password-stdin

Намучался

        yc managed-kubernetes cluster get-credentials --name=kube-infra --external  

        kubectl cluster-info                                                             
        Kubernetes control plane is running at https

        kubectl create namespace yc-alb-ingress namespace/yc-alb-ingress created

        helm pull oci://cr.yandex/yc/yc-alb-ingress-controller-chart \
        --version=v0.1.3 \
        --untar \
        --untardir=charts
        Pulled: cr.yandex/yc/yc-alb-ingress-controller-chart:v0.1.3
        Digest: sha256:6545c8d2353242435f3eea4fec403f2cbdba2a9b3677b7b65aab511e71d9ab73

Устанавливаем чарт в кластер:

        export FOLDER_ID=$(yc config get folder-id)
        export CLUSTER_ID=$(yc managed-kubernetes cluster get kube-infra | head -n 1 | awk -F ': ' '{print $2}')

        helm install --create-namespace --namespace yc-alb-ingress --set folderId=$FOLDER_ID --set clusterId=$CLUSTER_ID --set-file saKeySecretKey=sa-key.json yc-alb-ingress-controller ./charts/yc-alb-ingress-controller-chart/

        # проверяем, что ресурсы создались
        kubectl -n yc-alb-ingress get all

Проверить как IP адреса заданы

        yc vpc address list
        +----------------------+------+--------------+----------+------+
        |          ID          | NAME |   ADDRESS    | RESERVED | USED |
        +----------------------+------+--------------+----------+------+
        | e9b0g9tjelqndndbe5sk |      | 51.250.0.22  | false    | true |
        | e9beitf6m671pipl0geh |      | 51.250.94.39 | false    | true |
        +----------------------+------+--------------+----------+------+

Проверить состояние IP clustera

        kubectl get svc
        NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
        kubernetes   ClusterIP   10.96.128.1   <none>        443/TCP   63m

## Ingress

        kubectl create namespace httpbin
        namespace/httpbin created

        kubectl -n httpbin apply -f manifests/httpbin.yaml
                deployment.apps/httpbin unchanged
                service/httpbin unchanged
                ingress.networking.k8s.io/httpbin created

Балансировщик создаётся в течение 3-5 минут. Можно проверить командой:

        yc application-load-balancer load-balancer list

Создадим сертификат на доменное имя, которое использовали ранее для приложения httpbin:

        yc certificate-manager certificate request \
        --name kube-infra \
        --domains "*.infra.msh762.ru" \
        --challenge dns 

        yc dns zone add-records --name msh762-zone --record "_acme-challenge.infra.msh762.ru. 600 CNAME <id_Заменить>.cm.yandexcloud.net."
