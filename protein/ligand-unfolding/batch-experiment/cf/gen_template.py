D_values = ['arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6',
            'arn:aws:braket:::device/qpu/d-wave/Advantage_system1']
D_name_map = {
    'arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6': 'DW2000Q6',
    'arn:aws:braket:::device/qpu/d-wave/Advantage_system1': 'AdvantS1'
}

M_values = ["1", "2", "3", "4"]

E_values = ['ml.c5.xlarge', 'ml.c5.2xlarge', 'ml.m5.4xlarge', 'ml.c5.4xlarge', 'ml.r5.12xlarge']

template_t = open("./t.template.yaml", "r").read()
template_b = open("./b.template.json", "r").read()
template_p = open("./p.template.json", "r").read()

template_t_out = []
template_b_out = []

for M in M_values:
    M_name = "M{}".format(M)
    for D in D_values:
        D_name = D_name_map[D]
        for E in E_values:
            E_name = "".join(E.split(".")[1:]).upper()
            template_t_new = template_t.replace("#D#", D_name).replace("#D_V#", D) \
                .replace("#M#", M_name).replace("#M_V#", M) \
                .replace("#E#", E_name).replace("#E_V#", E)
            # print(template_t_new)
            # print("\n\n")
            template_t_out.append(template_t_new)
            job_name = "{}_{}_{}".format(M_name, D_name, E_name)
            template_b_out.append(template_b.replace("#J#", job_name))

template_p_out = template_p.replace("#B#", ",\n\n".join(template_b_out))

with open("p.json", "w") as out:
    out.write(template_p_out)

with open("t.yaml", "w") as out:
    out.write("\n\n".join(template_t_out))
