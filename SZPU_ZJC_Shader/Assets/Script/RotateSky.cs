using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateSky : MonoBehaviour
{
    public Material mat;

    void Update()
    {
        mat.SetFloat("_Rotation",Time.time % 360);
    }
}
