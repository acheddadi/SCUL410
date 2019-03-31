using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    private void Start()
    {
        Cursor.visible = false;
    }
    // Update is called once per frame
    void Update ()
    {
        if (Input.GetKey("escape"))
        {
            Application.Quit();
        }
    }
}
