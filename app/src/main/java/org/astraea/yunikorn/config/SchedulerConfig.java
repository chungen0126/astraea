package org.astraea.yunikorn.config;

import java.util.List;
import lombok.*;
@Getter @Setter
public class SchedulerConfig {

    private List<PartitionConfig> partitions;
    private String checksum;

}
