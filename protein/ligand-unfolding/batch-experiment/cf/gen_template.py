D_values = ['arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6',
            'arn:aws:braket:::device/qpu/d-wave/Advantage_system1']
D_name_map = {
    'arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6': 'DW2000Q6',
    'arn:aws:braket:::device/qpu/d-wave/Advantage_system1': 'AdvantS1'
}

M_values = ["1", "2", "3", "4"]

E_values = ['ml.c5.4xlarge', 'ml.m5.4xlarge', 'ml.r5.4xlarge']

template_t = open("./t.template.yaml", "r").read()
template_md = open("./md.template.yaml", "r").read()
template_m = open("./m.template.yaml", "r").read()
template_all = open("./a.template.yaml", "r").read()

template_t_out = []
template_md_out = []
template_m_out = []

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
        template_md_new = template_md.replace("#D#", D_name).replace("#M#", M_name)
        template_md_out.append(template_md_new)
    template_m_new = template_m.replace("#M#", M_name)
    template_m_out.append(template_m_new)


content = []
content.extend(template_t_out)
content.extend(template_md_out)
content.extend(template_m_out)

all_content = template_all.replace("#__CONTENT__#", "\n\n".join(content))

with open("qc-batch.g.yaml", "w") as out:
    out.write(all_content)
