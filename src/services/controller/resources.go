package controller

import (
	"k8s.io/kubernetes/pkg/api"
	"k8s.io/kubernetes/pkg/util/intstr"
)

func (s *apiServer) getOperatordRC(secret *api.Secret) *api.ReplicationController {
	return &api.ReplicationController{
		ObjectMeta: api.ObjectMeta{
			Name:   s.operatord.Name,
			Labels: map[string]string{"app": s.operatord.Name},
		},
		Spec: api.ReplicationControllerSpec{
			Replicas: 1,
			Template: &api.PodTemplateSpec{
				ObjectMeta: api.ObjectMeta{
					Labels: map[string]string{
						"app": s.operatord.Name,
					},
				},
				Spec: api.PodSpec{
					Volumes: []api.Volume{
						{
							Name: "secrets",
							VolumeSource: api.VolumeSource{
								Secret: &api.SecretVolumeSource{
									SecretName: secret.Name,
								},
							},
						},
					},
					Containers: []api.Container{
						{
							Name:    s.operatord.Name,
							Image:   s.operatord.DefaultImage,
							Command: []string{s.operatord.Command},
							VolumeMounts: []api.VolumeMount{
								{
									Name:      "secrets",
									MountPath: "/secrets",
									ReadOnly:  true,
								},
							},
							Ports: []api.ContainerPort{
								{
									Name:          s.operatord.Name,
									HostPort:      s.operatord.Port,
									ContainerPort: s.operatord.Port,
								},
							},
						},
					},
				},
			},
		},
	}
}

func (s *apiServer) getOperatordService() *api.Service {
	return &api.Service{
		ObjectMeta: api.ObjectMeta{
			Name:   s.operatord.Name,
			Labels: map[string]string{"app": s.operatord.Name},
		},
		Spec: api.ServiceSpec{
			Type:     api.ServiceTypeLoadBalancer,
			Selector: map[string]string{"app": s.operatord.Name},
			Ports: []api.ServicePort{
				{
					Name:       s.operatord.PortName,
					Protocol:   api.ProtocolTCP,
					Port:       s.operatord.Port,
					TargetPort: intstr.FromInt(s.operatord.Port),
				},
			},
		},
	}
}

func (s *apiServer) getHubotRC(secret *api.Secret) *api.ReplicationController {
	return &api.ReplicationController{
		ObjectMeta: api.ObjectMeta{
			Name:   s.hubot.Name,
			Labels: map[string]string{"app": s.hubot.Name},
		},
		Spec: api.ReplicationControllerSpec{
			Replicas: 1,
			Template: &api.PodTemplateSpec{
				ObjectMeta: api.ObjectMeta{
					Labels: map[string]string{
						"app": s.hubot.Name,
					},
				},
				Spec: api.PodSpec{
					Volumes: []api.Volume{
						{
							Name: "secrets",
							VolumeSource: api.VolumeSource{
								Secret: &api.SecretVolumeSource{
									SecretName: secret.Name,
								},
							},
						},
					},
					Containers: []api.Container{
						{
							Name:    s.hubot.Name,
							Image:   s.hubot.DefaultImage,
							Command: []string{s.hubot.Command},
							VolumeMounts: []api.VolumeMount{
								{
									Name:      "secrets",
									MountPath: "/secrets",
									ReadOnly:  true,
								},
							},
						},
					},
				},
			},
		},
	}
}
