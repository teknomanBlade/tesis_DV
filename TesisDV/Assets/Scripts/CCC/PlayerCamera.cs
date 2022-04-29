using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
    public Player _player;
    public GameObject _camera;
    private Quaternion targetAngle;
    private float smoothing = 15f;
    private Vector3 offset = new Vector3(0f, 0.75f, 0f);

    //Bobbing
    private Vector3 _initPos;
    private float _toggleSpeed = 0.3f;
    private float _amplitude = 0.005f;
    private float _frequency = 10.0f;

    private void Awake()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        _camera = GameObject.Find("MainCamera");
        _initPos = _camera.transform.localPosition;
    }

    private void LateUpdate()
    {
        CheckMotion();
        ResetPosition();

        transform.position = Vector3.Lerp(transform.position, _player.transform.position + offset, smoothing * Time.deltaTime);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetAngle, smoothing * Time.deltaTime);
    }

    public void ChangeAngles(Vector3 angles)
    {
        targetAngle = Quaternion.Euler(angles.x, angles.y, angles.z);
    }

    private void CheckMotion()
    {
        var pSpeed = _player.GetVelocity();
        float speed = new Vector3(pSpeed.x, 0, pSpeed.z).magnitude;

        if (speed < _toggleSpeed) return;
        if (!_player.isGrounded) return;
        PlayMotion(FootStepMotion());
    }

    private Vector3 FootStepMotion()
    {
        Vector3 pos = Vector3.zero;
        pos.y += Mathf.Sin(Time.time * _frequency) * _amplitude;
        pos.x += Mathf.Cos(Time.time * _frequency / 2) * _amplitude * 2;
        return pos;
    }

    private void ResetPosition()
    {
        if (_camera.transform.localPosition == _initPos) return;
        _camera.transform.localPosition = Vector3.Lerp(_camera.transform.localPosition, _initPos, 1 * Time.deltaTime);
    }

    private void PlayMotion(Vector3 motion)
    {
        _camera.transform.localPosition += motion;
    }
}
