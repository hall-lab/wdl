version 1.0
import "SV_Tasks.wdl" as SV

workflow Merge_SV {
  input {
    # data inputs
    File manta_input_vcfs_list
    File smoove_input_vcfs_list
    String cohort_name

    # system inputs
    Int disk_size
    Int preemptible_tries
  }

  Array[File] manta_input_vcfs = read_lines(manta_input_vcfs_list)
  Array[File] smoove_input_vcfs = read_lines(smoove_input_vcfs_list)
  
  call SV.L_Sort_VCF_Variants as lsort_manta {
    input:
    input_vcfs = manta_input_vcfs,
    output_vcf_basename = cohort_name + ".manta.lsort",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.Filter_Pass as filter_manta {
    input:
    input_vcf_gz = lsort_manta.output_vcf_gz,
    output_vcf_basename = cohort_name + ".manta.filter",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.L_Merge_VCF_Variants as lmerge_manta {
    input:
    input_vcf_gz = filter_manta.output_vcf_gz,
    output_vcf_basename = cohort_name + ".manta.lmerge",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.L_Sort_VCF_Variants as lsort_smoove {
    input:
    input_vcfs = smoove_input_vcfs,
    output_vcf_basename = cohort_name + ".smoove.lsort",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.Filter_Del as filter_smoove {
    input:
    input_vcf_gz = lsort_smoove.output_vcf_gz,
    output_vcf_basename = cohort_name + ".smoove.filter",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.L_Merge_VCF_Variants as lmerge_smoove {
    input:
    input_vcf_gz = filter_smoove.output_vcf_gz,
    output_vcf_basename = cohort_name + ".smoove.lmerge",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.L_Sort_VCF_Variants as lsort_manta_smoove {
    input:
    input_vcfs = [lmerge_manta.output_vcf_gz, lmerge_smoove.output_vcf_gz],
    output_vcf_basename = cohort_name + ".manta_smoove.lsort",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  call SV.L_Merge_VCF_Variants as lmerge_manta_smoove {
    input:
    input_vcf_gz = lsort_manta_smoove.output_vcf_gz,
    output_vcf_basename = cohort_name + ".manta_smoove.lmerge",
    disk_size = disk_size,
    preemptible_tries = preemptible_tries
  }

  output {
    File output_vcf = lmerge_manta_smoove.output_vcf_gz
  }
}
