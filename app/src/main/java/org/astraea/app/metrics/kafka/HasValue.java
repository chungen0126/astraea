/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.astraea.app.metrics.kafka;

import org.astraea.app.metrics.HasBeanObject;
import org.astraea.app.metrics.jmx.BeanObject;

public interface HasValue extends HasBeanObject {
  default long value() {
    var value = beanObject().getAttributes().getOrDefault("Value", 0);
    return ((Number) value).longValue();
  }

  static HasValue of(BeanObject beanObject) {
    return () -> beanObject;
  }
}
