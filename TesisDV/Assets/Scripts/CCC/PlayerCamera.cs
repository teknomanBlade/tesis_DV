using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
    private Player _player;
    private Vector3 initPos;

    //Bobbing
    private float transitionSpeed = 20f;
    private float timer = Mathf.PI / 2;
    private float bobSpeed = 4.8f;
    private float bobAmount = 0.1f;

    private void Start()
    {
        initPos = transform.localPosition;
        if (_player == null) _player = GetComponentInParent<Player>();
    }

    private void Update()
    {
        Bobbing();
    }

    public void ChangePitch(Vector3 pitch)
    {
        transform.localEulerAngles = pitch;
    }

    public void Bobbing()
    {
        Vector3 pVel = _player.GetVelocity();
        if (Mathf.Abs(pVel.x) >= 0.05f  || Mathf.Abs(pVel.z) >= 0.05f)
        {
            timer += bobSpeed * Time.deltaTime;
            transform.localPosition = new Vector3(Mathf.Cos(timer) * bobAmount, initPos.y + Mathf.Abs((Mathf.Sin(timer) * bobAmount)), initPos.z);
        } else
        {
            timer = Mathf.PI / 2;
            transform.localPosition = new Vector3(Mathf.Lerp(transform.localPosition.x, initPos.x, transitionSpeed * Time.deltaTime), Mathf.Lerp(transform.localPosition.y, initPos.y, transitionSpeed * Time.deltaTime), Mathf.Lerp(transform.localPosition.z, initPos.z, transitionSpeed * Time.deltaTime));
        }

        if (timer > Mathf.PI * 2) timer = 0;
    }
}
