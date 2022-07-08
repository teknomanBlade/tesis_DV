using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MiniMapCamera : MonoBehaviour
{
    // Start is called before the first frame update
    public Player _player;
    private float smoothing = 20f;
    private Vector3 offset = new Vector3(0f, 10, 0f);

    void Awake()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();

    }

    // Update is called once per frame
    void LateUpdate()
    {
        transform.position = Vector3.Lerp(transform.position, _player.transform.position + offset, smoothing * Time.deltaTime);
    }
}
