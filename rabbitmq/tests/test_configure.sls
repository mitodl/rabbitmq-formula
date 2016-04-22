test_rabbitmq_config:
  testinfra.file:
    - name: /etc/rabbitmq/rabbitmq.config
    - exists: True
    - contains:
        parameter: vm_memory_high_watermark
        expected: True
        comparison: is_
