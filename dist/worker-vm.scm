(use-modules (gnu)
	     (gnu image)
	     (gnu system image))
(load "../config/worker.scm")
(image
 (inherit mbr-disk-image)
 (name 'starter-image)
 (format 'compressed-qcow2)
 (operating-system (worker-node "generic-worker"))
 (partitions
  (list (partition
	 (inherit root-partition)
	 (file-system "ext4")
	 (offset root-offset)
	 (size (* 99  1024 1024 1024)))))
 (volatile-root? #false))
