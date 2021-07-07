import io

import numpy as np
import pandas as pd

from input_processing.visualization import VisOpen3D
import open3d as o3d
import cv2


def point_cloud_to_depth_image(pcd, use_voxel_filter=True, voxel_size=0.02,
                               view_point_config_file='input_processing/view_point.json', width=750,
                               height=550):
    vis = VisOpen3D(width=width, height=height, visible=False)

    geometry = o3d.geometry.VoxelGrid.create_from_point_cloud(pcd, voxel_size=voxel_size) if use_voxel_filter else pcd

    vis.add_geometry(geometry)
    vis.load_view_point(view_point_config_file)

    depth_image = np.asarray(vis.capture_depth_float_buffer(show=False)).astype(np.float32)

    return depth_image


def unorganized_point_cloud_to_open3d_format(unorganized_pc, rotation_angles=(np.pi / 2, np.pi / 2, 0), normalize=True):
    xyz = unorganized_pc[:, :3]
    xyz = (xyz - xyz.min()) / (xyz.max() - xyz.min()) if normalize else xyz
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(xyz)
    rotation_matrix = pcd.get_rotation_matrix_from_xyz(rotation_angles)

    pcd.rotate(rotation_matrix)
    return pcd


def resize_image(image, dsize):
    return cv2.resize(image, dsize=dsize, interpolation=cv2.INTER_CUBIC)


def raw_point_cloud_to_numpy(raw_point_cloud, skiprows=3, sep=';'):
    unorganized_pc = pd.read_csv(io.StringIO(raw_point_cloud), skiprows=skiprows, sep=sep).to_numpy()
    return unorganized_pc
