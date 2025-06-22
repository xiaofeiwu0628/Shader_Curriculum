using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class Metarila : MonoBehaviour
{
    public Material mat;
    public Transform m_targetObj;
    void Update()
    {
        mat.SetVector("_targetpos", m_targetObj.position);

    }
}