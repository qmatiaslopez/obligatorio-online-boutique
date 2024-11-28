#!/bin/bash

# Colores para la salida
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nc='\033[0m'

# Variables personalizadas del frontend
export cymbal_branding="false"
export enable_assistant="false"
export frontend_message="¡Bienvenido a nuestra tienda online!"
export packaging_service_url=""

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${red}Error: $1${nc}"
        exit 1
    fi
}

# Directorios base
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_root="$( cd "$script_dir/../../" && pwd )"
terraform_dir="$project_root/terraform"
manifests_dir="$project_root/k8s/manifests"

# Verificar que exista terraform.tfvars
if [ ! -f "$terraform_dir/terraform.tfvars" ]; then
    echo -e "${red}Error: No se encontró terraform.tfvars en: $terraform_dir${nc}"
    exit 1
fi

# Obtener valores de terraform.tfvars
export aws_region=$(grep 'region' "$terraform_dir/terraform.tfvars" | cut -d'=' -f2 | tr -d '" ' | tr -d '"')
export project_name=$(grep 'project_name' "$terraform_dir/terraform.tfvars" | cut -d'=' -f2 | tr -d '" ' | tr -d '"')
export namespace=$(grep 'app_namespace' "$terraform_dir/terraform.tfvars" | cut -d'=' -f2 | tr -d '" ' | tr -d '"')

# Obtener el ID de la cuenta de AWS
export aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text --region "${aws_region}")
if [ -z "$aws_account_id" ]; then
    echo -e "${red}Error: No se pudo obtener el ID de la cuenta de AWS${nc}"
    exit 1
fi

# Depuración: Mostrar directorios y variables
echo -e "${yellow}Información de depuración:${nc}"
echo "SCRIPT_DIR: $script_dir"
echo "PROJECT_ROOT: $project_root"
echo "TERRAFORM_DIR: $terraform_dir"
echo "MANIFESTS_DIR: $manifests_dir"
echo "AWS_ACCOUNT_ID: $aws_account_id"
echo "AWS_REGION: $aws_region"
echo "PROJECT_NAME: $project_name"
echo "NAMESPACE: $namespace"
echo "CYMBAL_BRANDING: $cymbal_branding"
echo "ENABLE_ASSISTANT: $enable_assistant"
echo "FRONTEND_MESSAGE: $frontend_message"
echo "Directorio actual: $(pwd)"

# Verificar que existan los directorios
if [ ! -d "$terraform_dir" ]; then
    echo -e "${red}Error: No se encontró el directorio de Terraform: $terraform_dir${nc}"
    exit 1
fi

if [ ! -f "${manifests_dir}/all-services.yaml" ]; then
    echo -e "${red}Error: No se encontró all-services.yaml en: $manifests_dir${nc}"
    exit 1
fi

echo -e "${green}Cambiando al directorio de Terraform: $terraform_dir${nc}"
cd "$terraform_dir"

# Obtener TARGET_GROUP_ARN de Terraform
export target_group_arn=$(terraform output -raw target_group_arn)
if [ -z "$target_group_arn" ]; then
    echo -e "${red}Error: No se pudo obtener target_group_arn de Terraform${nc}"
    exit 1
fi

# Verificar que se obtuvieron todos los valores requeridos
for var in aws_account_id aws_region project_name namespace target_group_arn; do
    if [ -z "${!var}" ]; then
        echo -e "${red}Error: La variable $var está vacía${nc}"
        exit 1
    fi
done

# Configurar el contexto
aws eks update-kubeconfig --region "${aws_region}" --name online-boutique-production

# Verificar la conexión al clúster
echo -e "${green}Verificando la conexión al clúster...${nc}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${red}Error: No se puede conectar al clúster de Kubernetes${nc}"
    echo "Verifique su configuración de kubectl y la conexión al clúster"
    exit 1
fi

# Crear el namespace si no existe
echo -e "${green}Creando el namespace $namespace si no existe...${nc}"
kubectl create namespace "${namespace}" --dry-run=client -o yaml | kubectl apply -f -
check_error "Error creando el namespace"


# Aplicar manifiestos
echo -e "${green}Aplicando manifiestos de Kubernetes...${nc}"
envsubst < "${manifests_dir}/all-services.yaml" | kubectl apply -f -
check_error "Error aplicando manifiestos"

# Esperar a que los pods existan primero
echo -e "${yellow}Esperando a que se creen los pods...${nc}"
while [[ $(kubectl get pods -n "${namespace}" 2>/dev/null | wc -l) -eq 0 ]]; do
    echo "Esperando a que se creen los pods..."
    sleep 5
done

# Una vez que existan, esperar a que estén listos
echo -e "${yellow}Esperando a que todos los pods estén listos...${nc}"
kubectl wait --namespace="${namespace}" \
    --for=condition=ready pods \
    --all \
    --timeout=300s

# Mostrar el estado de los recursos
echo -e "${green}Estado de los deployments:${nc}"
kubectl get deployments -n "${namespace}" -o wide

echo -e "${green}Estado de los servicios:${nc}"
kubectl get services -n "${namespace}" -o wide

echo -e "${green}Estado de los pods:${nc}"
kubectl get pods -n "${namespace}" -o wide

# Obtener la URL de ALB
echo -e "${green}Obteniendo la URL de ALB...${nc}"
alb_url=$(aws elbv2 describe-load-balancers \
    --region "${aws_region}" \
    --names "${project_name}-frontend" \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

if [ -n "$alb_url" ]; then
    echo -e "${green}La aplicación está disponible en: http://${alb_url}${nc}"
    
    # Verificar si el servicio está respondiendo
    echo -e "${yellow}Verificando el acceso a la aplicación...${nc}"
    for i in {1..6}; do
        if curl -s -f -m 5 "http://${alb_url}/_healthz" > /dev/null; then
            echo -e "${green}¡La aplicación está respondiendo correctamente!${nc}"
            break
        fi
        echo -n "."
        sleep 10
        if [ $i -eq 6 ]; then
            echo -e "${yellow}Advertencia: La aplicación aún no está respondiendo. Puede tardar unos minutos más.${nc}"
        fi
    done
else
    echo -e "${red}No se pudo obtener la URL de ALB${nc}"
fi

echo -e "${green}¡Implementación completada!${nc}"