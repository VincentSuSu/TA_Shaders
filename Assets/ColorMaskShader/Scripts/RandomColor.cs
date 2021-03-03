using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomColor : MonoBehaviour {

    Renderer[] Rend;
    Color primColor;
    public float primMinValue = 0.5f;
    public float primMaxValue = 0.8f;
    Color secColor;
    public float secMinValue = 0.5f;
    public float secMaxValue = 0.8f;
    Color terColor;
    public float terMinValue = 0.5f;
    public float terMaxValue = 0.8f;

    // Use this for initialization
    void Start () {
        Rend = GetComponentsInChildren<Renderer>();
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetMouseButtonDown(0)){
            GenerateColors();
        }
    }

    void GenerateColors()
    {
        primColor = Random.ColorHSV(0f, 1f, 0.7f, 1f, primMinValue,primMaxValue);
        secColor = Random.ColorHSV(0f, 1f, 0.7f, 1f, secMinValue, secMaxValue);
        terColor = Random.ColorHSV(0f, 1f, 0.7f, 1f, terMinValue, terMaxValue);
        for (int i = 0; i < Rend.Length; i++)
        {
            Rend[i].material.SetColor("_ColorPrim", primColor);
            Rend[i].material.SetColor("_ColorSec", secColor);
            Rend[i].material.SetColor("_ColorTert", terColor);
        }
       
    }
}
