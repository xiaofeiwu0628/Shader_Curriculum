using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class OpenLight : MonoBehaviour
{
    public GameObject _light;
    private bool isOpen = false;

    void Awake()
    {
        GetComponent<Button>().onClick.AddListener(ChangeLight);
    }

    void ChangeLight()
    {
        _light.SetActive(isOpen = !isOpen);
    }
}
