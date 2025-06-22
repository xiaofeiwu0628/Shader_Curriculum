using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlackHole : MonoBehaviour
{
    public Material mat;
    public Transform m_targetObj;
    void Start()
    {
        // mat = meshRenderer.GetComponent<Material>();
    }

    
    void Update()
    {
        mat.SetVector("_BlackHole",m_targetObj.position);
    }
}
