import numpy
import numpy as np

from input_processing.process_point_cloud import unorganized_point_cloud_to_open3d_format


def covert_grasping_points_to_input_reference(grasps, unorganized_pc,depth_image,frame_size=(300,300)):
    open3d_pcd = unorganized_point_cloud_to_open3d_format(unorganized_pc,normalize=False)

    pct_xy = numpy.array(grasps[0].center)/numpy.array(frame_size)
    pct_xyz = numpy.append(pct_xy,depth_image[grasps[0].center])
    min_bound = open3d_pcd.get_min_bound()
    max_bound = open3d_pcd.get_max_bound()
    bound_diff = max_bound - min_bound

    out = min_bound + pct_xyz*bound_diff
    #out = np.array(out).flatten()
    print(pct_xyz)
    print(out)
    print(min_bound)
    print(max_bound)