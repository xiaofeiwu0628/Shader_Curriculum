using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class AlphaSlider : MonoBehaviour
{
    public Slider silder;
    private Material mat;

    public void Awake()
    {
        silder.onValueChanged.AddListener(SetValue);
        silder.gameObject.SetActive(false);
        GetComponent<Button>().onClick.AddListener(SetAlphaSlider);
    }


    public void SetValue(float v)
    {
        if (mat.name == "AlphaTest"||mat.name == "AlphaTestBoth")
        {
            mat.SetFloat("_Cutoff", v);
        }
        else
        {
            mat.SetFloat("_AlphaScale", v);
        }
    }

    public void SetAlphaSlider()
    {
        if (silder.gameObject.activeInHierarchy)
        {
            silder.gameObject.SetActive(false);
            // CameraController.instance.SetisChange(true);
            GetComponentInChildren<TextMeshProUGUI>().text = "On";
        }
        else
        {
            silder.gameObject.SetActive(true);
            // CameraController.instance.SetisChange(false);
            GetComponentInChildren<TextMeshProUGUI>().text = "Off";
        }
        
    }

    public void SetMat(Material _mat)
    {
        mat = _mat;
    }
}
