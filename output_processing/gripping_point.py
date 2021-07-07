import numpy
import numpy as np

from input_processing.process_point_cloud import unorganized_point_cloud_to_open3d_format


def covert_grasping_points_to_input_reference(grasps, unorganized_pc,depth_image,frame_size=(300,300)):
    open3d_pcd = unorganized_point_cloud_to_open3d_format(unorganized_pc,normalize=False)
    min_bound = open3d_pcd.get_min_bound()
    max_bound = open3d_pcd.get_max_bound()
    bound_diff = max_bound - min_bound
    processed_grasps = np.array([])
    for grasp in grasps:
        pct_xy = numpy.array(grasp.center)/numpy.array(frame_size)
        pct_xyz = numpy.append(pct_xy, depth_image[grasp.center])
        processed_grasp_point = min_bound + pct_xyz * bound_diff
        processed_grasp = np.append(np.append(processed_grasp_point, grasp.width), grasp.angle)
        processed_grasps = np.append(processed_grasps, processed_grasp)

    rows = np.shape(grasps)[0]
    processed_grasps = processed_grasps.reshape((rows,5))
    return processed_grasps