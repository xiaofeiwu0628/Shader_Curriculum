using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MyTest : MonoBehaviour
{
    public Slider slider;
    public SkinnedMeshRenderer mesh;
    Material[] mat;

    void Start()
    {
        slider.onValueChanged.AddListener(Change);
        mat = mesh.materials;
        for(int i =0;i<mat.Length;i++)
        {
            
            mat[i].SetFloat("_R",0.125f);
            mat[i].SetFloat("_Mask",1.5f);
        }

    }

    void Change(float v)
    {
        v = v * 1.5f;
        for(int i=0;i<mat.Length;i++)mat[i].SetFloat("_Mask",1.5f - v);
    }
    
}
