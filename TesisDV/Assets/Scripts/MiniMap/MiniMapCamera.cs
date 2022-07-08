using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MiniMapCamera : MonoBehaviour
{
    // Start is called before the first frame update
    public Player _player;
    private float smoothing = 3f;
    private Vector3 offset = new Vector3(0f, 10, 0f);


    [SerializeField]
    private float leftLimit;
    [SerializeField]
    private float rightLimit;
    [SerializeField]
    private float topLimit;
    [SerializeField]
    private float bottomLimit;

    [SerializeField]
    Vector3 posOffset;

    void Awake()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();

    }

    // Update is called once per frame
    void Update()
    {
        Vector3 endPos = _player.transform.position;

        endPos.x += posOffset.x;
        endPos.y = transform.position.y;
        endPos.x += posOffset.z;



        transform.position = Vector3.Lerp(transform.position, endPos, smoothing * Time.deltaTime);
        transform.position = new Vector3(Mathf.Clamp(transform.position.x, leftLimit, rightLimit), transform.position.y, Mathf.Clamp(transform.position.z, topLimit, bottomLimit));
    }

    private void OnDrawGizmos()
    {

    }
}
