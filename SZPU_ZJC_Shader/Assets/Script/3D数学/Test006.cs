using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class Test006 : MonoBehaviour
{
    public float Speed = 2;
    public KeyCode key;
    private Vector3 targetPos;
    private Vector3 targetScl;
    private Quaternion targetQue;

    void Awake()
    {
        targetPos = transform.position;
        targetScl = transform.localScale;
        targetQue = transform.rotation;
    }


    void Update()
    {
        if (Input.GetKeyDown(key))
        {
            Vector3 rand = new Vector3(Random.Range(1, 10), Random.Range(1, 10), Random.Range(1, 10));
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, 1000, LayerMask.GetMask("Cube")))
            {
                Vector3 pos = hit.point;
                Matrix4x4 t1 = MyTranslate(pos);
                Matrix4x4 t2 = MySclic(rand);
                Matrix4x4 t3 = MyRotation(rand);
                Matrix4x4 t = t1 * t2;
                // Debug.Log($"复合矩阵：\n{t}");
                // Debug.Log($"旋转矩阵：\n{t3}");

                Vector4 v = new Vector4(0, 0, 0, 1);
                v = t * v;
                // Debug.Log($"位移矩阵的值：\n{v}");
                targetPos = new Vector3(v.x, v.y, v.z);
                //旋转
                float qw = Mathf.Sqrt(1 + t3.m00 + t3.m11 + t3.m22) / 2;
                float w = 4 * qw;
                float qx = transform.rotation.x + (t3.m21 - t3.m12) / w;
                float qy = transform.rotation.y + (t3.m02 - t3.m20) / w;
                float qz = transform.rotation.z + (t3.m10 - t3.m01) / w;
                targetQue = new Quaternion(qx, qy, qz, qw);
                // Debug.Log($"旋转矩阵的值：\n{qx},{qy},{qz},{qw}");

                //Vector3 s = transform.localScale;
                Vector3 s = new Vector3(1, 1, 1);
                s = t * s;
                targetScl = s;
            }
        }
    }

    private void FixedUpdate()
    {
        transform.position = Vector3.Lerp(transform.position, targetPos, Time.deltaTime * Speed);
        transform.localScale = Vector3.Lerp(transform.localScale, targetScl, Time.deltaTime * Speed);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetQue, Time.deltaTime * Speed);
    }

    Matrix4x4 MyTranslate(Vector3 pos)
    {
        // 对角矩阵
        Matrix4x4 a = Matrix4x4.identity;

        a.m03 = pos.x;
        a.m13 = pos.y;
        a.m23 = pos.z;
        //Debug.Log("v" + v);
        return a;
    }

    Matrix4x4 MyRotation(Vector3 v)
    {
        Matrix4x4 x = Matrix4x4.identity;
        Matrix4x4 y = Matrix4x4.identity;
        Matrix4x4 z = Matrix4x4.identity;

        //对应 X、Y、Z的旋转


        x.m11 = Mathf.Cos(v.x * Mathf.Deg2Rad);
        x.m12 = -Mathf.Sin(v.x * Mathf.Deg2Rad);
        x.m21 = Mathf.Sin(v.x * Mathf.Deg2Rad);
        x.m22 = Mathf.Cos(v.x * Mathf.Deg2Rad);

        y.m00 = Mathf.Cos(v.y * Mathf.Deg2Rad);
        y.m02 = Mathf.Sin(v.y * Mathf.Deg2Rad);
        y.m20 = -Mathf.Sin(v.y * Mathf.Deg2Rad);
        y.m22 = Mathf.Cos(v.y * Mathf.Deg2Rad);

        z.m00 = Mathf.Cos(v.z * Mathf.Deg2Rad);
        z.m01 = -Mathf.Sin(v.z * Mathf.Deg2Rad);
        z.m10 = Mathf.Sin(v.z * Mathf.Deg2Rad);
        z.m11 = Mathf.Cos(v.z * Mathf.Deg2Rad);
        return x * y * z;
    }

    Matrix4x4 MySclic(Vector3 pos)
    {
        Matrix4x4 a = Matrix4x4.identity;
        a.m00 = pos.x;
        a.m11 = pos.y;
        a.m22 = pos.z;
        return a;
    }
}
